<?xml version="1.0" encoding="utf-8"?>

<!--
  RFC 3339 date and time basic operations for XSLT 1.0.
  
  @namespace urn:qc:date
  @author Savva Mikhalevski <smikhalevski@gmail.com>
  @summary date:timestamp($date-time)
           date:date-time($timestamp)
           date:set-timezone($date-time,$offset='+00:00')
           date:duration($msec,$format='')
  -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="urn:qc:date"
                extension-element-prefixes="date">

    <date:month>
        <january>31</january>
        <february>28</february>
        <march>31</march>
        <april>30</april>
        <may>31</may>
        <june>30</june>
        <july>31</july>
        <august>31</august>
        <september>30</september>
        <october>31</october>
        <november>30</november>
        <december>31</december>
    </date:month>

    <xsl:decimal-format name="date:f"
                        NaN="0"/>

    <xsl:variable name="date:month"
                  select="document('')//date:month"/>

    <!--
      Calculates difference in milliseconds between midnight 1970-01-01 and
      provided date. Timestamp is UTC compliant: {@link Date#setTime} would
      set valid UTC date in JavaScript. In case invalid format is used then
      empty string is returned.

      @param $date-time [optional|.] date-time string.
             Accepted date-time format is subset of RFC 3339:
             [-|+]yyyy[-MM[-dd(T|_)[hh:mm[:ss[.μ]][Z|(+|-)hh:mm]]]]
      @see http://tools.ietf.org/html/rfc3339
      @output int
      -->
    <xsl:template name="date:timestamp">
        <xsl:param name="date-time" select="."/>
        <xsl:variable name="compact"
                      select="
             normalize-space(
                 translate($date-time,'TZ ',''))"/>
        <xsl:variable name="year"
                      select="
             translate(
                 substring($compact,1,
                     4+(starts-with($compact,'+') or
                        starts-with($compact,'-'))),
                 '+','')"/>
        <xsl:variable name="date"
                      select="substring-after($compact,$year)"/>
        <xsl:variable name="time"
                      select="substring($date,7)"/>
        <xsl:variable name="month"
                      select="format-number(substring($date,2,2)-1,0,'date:f')"/>
        <xsl:variable name="utc-offset">
            <xsl:variable name="raw"
                          select="
                 concat(
                     substring-after($time,'+'),
                     substring-after($time,'-'))"/>
            <xsl:value-of select="
                 format-number(
                     (contains($time,'-')-.5)
                     *2*(substring($raw,1,2)*60
                        +substring($raw,4,2)),0,'date:f')"/>
        </xsl:variable>
        <xsl:value-of select="
             translate(
                 1000*(
                     24*3600*(
                         $year*365-719527
                             +floor($year div 4)
                             -floor($year div 100)
                             +floor($year div 400)
                         +sum($date:month/*[$month>=position()])
                         +format-number(substring($date,5,2)-1,0,'date:f')
                         -(2>$month and (($year mod 4=0 and
                                          $year mod 100!=0) or
                                          $year mod 400=0)))
                     +format-number(
                         concat(0,substring($time,7,
                                 (substring($time,6,1)=':')*2))
                         +substring($time,1,2)*3600
                         +substring($time,4,2)*60,0,'date:f')
                     +$utc-offset*60)
                 +format-number(
                     round(
                         (substring($time,9,1)='.')
                         *1000*substring-before(
                             translate(
                                 concat('0.',substring-after($time,'.'),'_'),
                                 '+-','__'),'_')),0,'date:f'),'NaN','')"/>
    </xsl:template>
    
    <!--
      Converts timestamp in millisecond to RFC 3339 compliant UTC date-time string.
      If provided timestamp cannot be converted to number, empty string is returned.
      
      @param $timestamp [optional|.] signed integer representing millisecond date
             offset from midnight 1970-01-01.
      @see http://tools.ietf.org/html/rfc3339
      @output [-]yyyy-MM-ddThh:mm:ss.μμμZ
      -->
    <xsl:template name="date:date-time">
        <xsl:param name="timestamp" select="."/>
        <xsl:variable name="day"
                      select="$timestamp div (24*3600000)"/>
        <xsl:if test="$day>=0 or 0>$day">
            <xsl:variable name="time"
                          select="
                 $timestamp div 1000
                -floor($day)*24*3600"/>
            <xsl:variable name="year"
                          select="
                 1970+floor(
                     format-number($day div 365.24,'0.#'))"/>
            <xsl:variable name="year-offset"
                          select="
                 719528-$year*365
                 -floor($year div 4)
                 +floor($year div 100)
                 -floor($year div 400)
                 +floor($day)"/>
            <xsl:variable name="month"
                          select="
                 count($date:month
                       /*[$year-offset>=sum(preceding-sibling::*)][last()]
                       /preceding-sibling::*)"/>
            <xsl:variable name="hour"
                          select="floor($time div 3600)"/>
            <xsl:variable name="min"
                          select="floor($time div 60-$hour*60)"/>
            <xsl:variable name="sec"
                          select="floor($time -$hour*3600-$min*60)"/>
            <xsl:value-of select="
                 concat(
                     format-number($year,'0000'),'-',
                     format-number($month+1,'00'),'-',
                     format-number(
                         $year-offset
                         -sum($date:month/*[$month>=position()])
                         +(2>$month and (($year mod 4=0 and
                                          $year mod 100!=0) or
                                          $year mod 400=0)),
                         '00'),'T',
                     format-number($hour,'00'),':',
                     format-number($min,'00'),':',
                     format-number($sec,'00'),'.',
                     format-number(
                         1000*($time
                         -$hour*3600
                         -$min*60-$sec),
                         '000'),'Z')"/>
        </xsl:if>
    </xsl:template>

    <!--
      Changes provided date-time string to match given timezone.
      When invalid format is provided empty string is returned.

      @param $date-time [optional|.] date-time string.
      @param $offset [optional|Z] timezone offset to shift date-time to.
             Required format is RFC 3339 compliant timezone:
             [[+|-]hh[:mm]|Z]. When Z or blank line is provided UTC time is returned.
      @see document()/date:date-time/$date-time
      @output [-]yyyy-MM-ddThh:mm:ss.μμμ(Z|(+|-)hh:mm)|""
      -->
    <xsl:template name="date:set-timezone">
        <xsl:param name="date-time" select="."/>
        <xsl:param name="offset"/>
        <xsl:variable name="timestamp">
            <xsl:call-template name="date:timestamp">
                <xsl:with-param name="date-time"
                                select="$date-time"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string-length($timestamp)>0">
            <xsl:variable name="hours"
                          select="
                 format-number(
                     translate(
                         substring-before(
                             concat($offset,':'),
                             ':'),'+',0),0,'date:f')"/>
            <xsl:variable name="min"
                          select="
                 format-number(
                     substring-after($offset,':'),
                     0,'date:f')"/>
            <xsl:variable name="shift"
                          select="
                 -120000*(contains($offset,'-')-.5)
                 *(60*translate($hours,'-',0)+$min)"/>
            <xsl:variable name="local">
                <xsl:call-template name="date:date-time">
                    <xsl:with-param name="timestamp"
                                    select="$timestamp+$shift"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="translate($local,'Z','')"/>
            <xsl:choose>
                <xsl:when test="$shift=0">Z</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="
                         concat(
                             format-number($hours,'+00;-00'),':',
                             format-number($min,'00'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <!--
      Converts provided μsec to a human readable form in requested format.
      
      @param $msec [optional|.] number of μsec.
      @param $format [optional] name of the format.
      @see http://www.w3.org/TR/xmlschema-2/#duration
      @output PdDThHmMs.μμμS|dDhh:mm:ss.μ|""
      -->
    <xsl:template name="date:duration">
        <xsl:param name="msec" select="."/>
        <xsl:param name="format"/>
        <xsl:if test="0>$msec">-</xsl:if>
        <xsl:variable name="time"
                      select="
             format-number(
                 round($msec) div 1000,
                 '0.###;0.###','date:f')"/>
        <xsl:variable name="day"
                      select="floor($time div (3600*24))"/>
        <xsl:variable name="hour"
                      select="floor($time div 3600-$day*24)"/>
        <xsl:variable name="min"
                      select="floor($time div 60-($day*24+$hour)*60)"/>
        <xsl:variable name="sec"
                      select="$time+-($day*24+$hour)*3600-$min*60"/>
        <xsl:choose>
            <xsl:when test="$format='xsd:duration'">
                <xsl:value-of select="
                     concat('P',
                         substring(
                             format-number($day,'0D'),
                             0 mod ($day!=0 or $time=0)),
                         substring('T',1,$hour+$min+$sec!=0),
                         substring(format-number($hour,'0H'),0 mod $hour),
                         substring(format-number($min,'0M'),0 mod $min),
                         substring(format-number($sec,'0.###S'),0 mod $sec))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="
                     concat(
                         substring(format-number($day,'0D'),0 mod $day),
                         substring(
                             format-number($hour,
                                 substring('00:',not($day)+1)),
                             0 mod ($day+$hour)),
                         substring(
                             concat(
                                 format-number($min,
                                     substring('00:',not($day+$hour)+1)),
                                 format-number($sec,'00')),
                             0 mod ($day+$hour+$min)),
                         substring(
                             format-number($time,'0.#'),
                             0 mod (60>$time)))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>