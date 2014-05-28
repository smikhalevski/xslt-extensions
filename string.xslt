<?xml version="1.0" encoding="utf-8"?>

<!--
  Complex operations with strings and nodesets for XSLT 1.0.
  
  @namespace urn:qc:string
  @author Savva Mikhalevski <smikhalevski@gmail.com>
  -->
<xsl:stylesheet version="1.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:string="urn:qc:string"
				xmlns:fn="http://exslt.org/common"
				extension-element-prefixes="string fn">
	
	<xsl:decimal-format name="string:f"
						NaN="0"/>

	<!--
	  @param $string:tab [optional] length of tab space-equivalent.
	  @param $string:nbsp [optional|&#160;] non-breakable space character.
	  -->
	<xsl:param name="string:tab">
		<xsl:text><![CDATA[    ]]></xsl:text>
	</xsl:param>
	<xsl:param name="string:nbsp">&#160;</xsl:param>

	<!--
	  Platform and encoding independent new-line character. XML parsers normalize
	  CR+LF to LF, except in attribute values containing a CR written as a numeric
	  character reference like &#13; so in XSLT you get only LF &#10;.
	  
	  @see http://www.w3.org/TR/newline
	  -->
	<xsl:variable name="string:eol">
		<xsl:text>&#10;</xsl:text>
	</xsl:variable>

	<!--
	  Returns nodeset where each element is a substring of string formed
	  by splitting input on boundaries formed by the string delimiter.
	  
	  @param $input [optional|.] input string.
	  @param $delimiter [optional|""] boundary string. Empty value
	         causes string to be splitted into separate characters.
	  @see http://www.php.net/manual/en/function.explode
	  @output string
	  -->
	<xsl:template name="string:explode">
		<xsl:param name="input" select="."/>
		<xsl:param name="delimiter"/>
        <xsl:variable name="_delimiter"
                      select="fn:node-set($delimiter)[name()]|fn:node-set($delimiter)[not(name())]/node()"/>
        <xsl:choose>
            <xsl:when test="string($_delimiter)=''">
                <fragment>
                    <xsl:value-of select="substring($input,1,1)"/>
                </fragment>
                <xsl:if test="string-length($input)>1">
                    <xsl:call-template name="string:explode">
                        <xsl:with-param name="input"
                                        select="substring($input,2)"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="nearest_delimiter">
                    <xsl:for-each select="$_delimiter[contains($input,.) and .!='']">
                        <xsl:sort select="string-length(substring-before($input,.))"
                                  order="ascending"
                                  data-type="number"/>
                        <xsl:if test="position()=1">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <fragment>
                    <xsl:value-of select="substring-before($input,$nearest_delimiter)"/>
                    <xsl:if test="string($nearest_delimiter)=''">
                        <xsl:value-of select="$input"/>
                    </xsl:if>
                </fragment>
                <xsl:if test="string($nearest_delimiter)!=''">
                    <xsl:call-template name="string:explode">
                        <xsl:with-param name="input"
                                        select="substring-after($input,$nearest_delimiter)"/>
                        <xsl:with-param name="delimiter"
                                        select="$delimiter"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

    <!--
	  Replaces all occurences of searched string with the given value.
	  
	  @param $input [optional|.] string to search in.
	  @param $search [required] character sequence to search for.
	         If omitted then no changes are made to input.
	  @param $replace [optional|""] string to substitute.
	  @see http://php.net/manual/en/function.str-replace
	  @output string
	  -->
    <xsl:template name="string:replace">
        <xsl:param name="input" select="."/>
        <xsl:param name="find"/>
        <xsl:param name="replace"/>
        <xsl:variable name="_find"
                      select="fn:node-set($find)[name()]|fn:node-set($find)[not(name())]/node()"/>
        <xsl:variable name="_replace"
                      select="fn:node-set($replace)[name()]|fn:node-set($replace)[not(name())]/node()"/>
        <xsl:variable name="delims"
                      select="$_find[contains($input,.) and .!='']"/>
        <xsl:for-each select="$delims">
            <xsl:sort select="string-length(substring-before($input,.))"
                      order="ascending"
                      data-type="number"/>
            <xsl:variable name="position">
                <xsl:variable name="cur"
                              select="."/>
                <xsl:for-each select="$_find">
                    <xsl:if test="count(.|$cur)=1">
                        <xsl:value-of select="position()"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="position()=1">
                <xsl:value-of select="
                     concat(
                         substring-before($input,.),
                         $_replace[position()=$position])"/>
                <xsl:call-template name="string:replace">
                    <xsl:with-param name="input"
                                    select="substring-after($input,.)"/>
                    <xsl:with-param name="find"
                                    select="$find"/>
                    <xsl:with-param name="replace"
                                    select="$replace"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
        <xsl:if test="not($delims)">
            <xsl:value-of select="$input"/>
        </xsl:if>
    </xsl:template>

    <!--
	  Repeats provided string given number of times.
	  
	  @param $input [optional|.] string to repeat.
	  @param $count [optional|1] integer number of repeats.
	  @see http://php.net/manual/en/function.str-repeat
	  @output string
	  -->
    <xsl:template name="string:repeat">
        <xsl:param name="input" select="."/>
        <xsl:param name="count">1</xsl:param>
        <xsl:if test="$count>0">
            <xsl:value-of select="$input"/>
            <xsl:call-template name="string:repeat">
                <xsl:with-param name="input"
								select="$input"/>
                <xsl:with-param name="count"
								select="$count+-1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="string:indent">
        <xsl:param name="input" select="."/>
        <xsl:param name="count"/>
        <xsl:variable name="lines">
            <xsl:call-template name="string:explode">
                <xsl:with-param name="input"
								select="$input"/>
                <xsl:with-param name="delimiter"
								select="$string:eol"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="_size"
                      select="format-number($count,'0','string:f')"/>
        <xsl:for-each select="fn:node-set($lines)/*">
            <xsl:variable name="text" select="normalize-space(translate(.,'&#9;',' '))"/>
            <xsl:variable name="leng" select="string-length(substring-before(.,substring($text,1,1)))"/>
            <xsl:if test="0>$_size">
                <xsl:if test="$text=''">
                    <xsl:value-of select="substring(.,-$_size+1)"/>
                </xsl:if>
                <xsl:if test="$text!=''">
                    <xsl:value-of select="substring(.,-$_size*($leng>-$_size)+$leng*(-$_size>=$leng)+1)"/>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$_size>=0">
                <xsl:call-template name="string:repeat">
                    <xsl:with-param name="input"
                                    select="' '"/>
                    <xsl:with-param name="count"
                                    select="$_size"/>
                </xsl:call-template>
                <xsl:value-of select="."/>
            </xsl:if>
            <xsl:if test="last()>position()">
                <xsl:value-of select="$string:eol"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="string:deflate">
        <xsl:param name="input" select="."/>
        <xsl:param name="condense"/>
        <xsl:variable name="lines">
            <xsl:call-template name="string:explode">
                <xsl:with-param name="input"
								select="$input"/>
                <xsl:with-param name="delimiter"
								select="$string:eol"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="size">
            <xsl:for-each select="fn:node-set($lines)/node()[normalize-space(translate(.,'&#9;',' '))]">
                <xsl:variable name="pad"
                              select="string-length(substring-before(.,substring(normalize-space(translate(.,'&#9;',' ')),1,1)))"/>
                <xsl:if test="
							not(
								preceding::node()[
									normalize-space(translate(.,'&#9;',' ')) and
									$pad>string-length(substring-before(.,substring(normalize-space(translate(.,'&#9;',' ')),1,1)))
								]
								or
								following::node()[
									normalize-space(translate(.,'&#9;',' ')) and
									$pad>=string-length(substring-before(.,substring(normalize-space(translate(.,'&#9;',' ')),1,1)))
								]
							)
							">
                    <xsl:value-of select="$pad"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="fn:node-set($lines)/node()[normalize-space(translate(.,'&#9;',' ')) 
					   or (preceding::node()[normalize-space(translate(.,'&#9;',' '))] and following::node()[normalize-space(translate(.,'&#9;',' '))] and not($condense))
					  ]">
            <xsl:value-of select="concat(
                          
                          substring(.,format-number($size,0,'string:f')+1)
                          
                          ,substring($string:eol,0 mod (last()>position())))"/>
        </xsl:for-each>
    </xsl:template>

	<!--
	  Converts any given nodeset into preformatted text by exploiting local
	  templates with {@code string:(xml|text)} modes.
	  
	  Note: Opera treats space and eol-filled blocks as text nodes, but stylesheet
	  has to preserve unity among parses from different vendors so all match-based
	  templates check normalized content for emptiness.
	  
	  @param $nodeset [optional|.] nodeset to format source of.
	  @see http://msdn.microsoft.com/library/aa301578.aspx
	  @output string
	  -->
	<xsl:template name="string:xml">
		<xsl:param name="nodeset"
				   select="."/>
		<xsl:apply-templates select="$nodeset"
							 mode="string:xml"/>
	</xsl:template>
	
	<xsl:template match="*"
				  mode="string:xml">
		<xsl:variable name="tag"
					  select="local-name()"/>
		<xsl:variable name="empty"
					  select="
			 not(descendant::* or
				 normalize-space(translate(.,'&#9;',' ')) or
				 comment()[normalize-space(translate(.,'&#9;',' '))])"/>
		<xsl:variable name="space">
			<xsl:call-template name="string:repeat">
				<xsl:with-param name="count"
								select="
					 string-length($string:tab)
					+string-length($tag)+2"/>
				<xsl:with-param name="input"
								select="$string:nbsp"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="concat($string:eol,'&lt;',$tag)"/>
		<xsl:for-each select="@*">
			<xsl:value-of select="
				 concat(
				     substring($space,1,
						  (position()>1)*(string-length($tag)+1)+1),
					 name(),'=&quot;')"/>
			<xsl:apply-templates select="."
								 mode="string:text"/>
			<xsl:value-of select="
						  concat('&quot;',
					 substring($string:eol,
					     0 mod (count(../@*)>position())))"/>
		</xsl:for-each>
		<xsl:if test="$empty">/</xsl:if>
		<xsl:text>&gt;</xsl:text>
		<xsl:if test="not($empty)">
			<xsl:variable name="xml">
				<xsl:call-template name="string:replace">
					<xsl:with-param name="find"
									select="$string:eol"/>
					<xsl:with-param name="replace"
									select="
						 concat($string:eol,
						     substring($space,1,
								 string-length($string:tab)))"/>
					<xsl:with-param name="input">
						<xsl:apply-templates select="*|comment()|text()"
											 mode="string:xml"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="
				 concat($xml,
				     substring($string:eol,
				         0 mod (contains($xml,$string:eol) or
						        count(@*)>1)),
					 '&lt;/',$tag,'>')"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text()"
				  mode="string:xml">
		<xsl:if test="normalize-space(translate(.,'&#9;',' '))">
			<xsl:variable name="text">
				<xsl:apply-templates select="."
									 mode="string:text"/>
			</xsl:variable>
			<xsl:value-of select="
				 concat(  
					 substring($string:eol,
						 0 mod ((../text() and ../comment()[normalize-space(translate(.,'&#9;',' '))]|../*) or
								contains($text,$string:eol) or
								count(../@*)>1)),
					 $text)"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="comment()"
				  mode="string:xml">
		<xsl:variable name="text">
			<xsl:apply-templates select="."
								 mode="string:text"/>
		</xsl:variable>
		<xsl:if test="normalize-space($text)">
			<xsl:variable name="eol"
						  select="
				 substring($string:eol,
				     0 mod contains($text,$string:eol))"/>
			<xsl:value-of select="concat($string:eol,'&lt;!-- ')"/>
			<xsl:call-template name="string:replace">
				<xsl:with-param name="find"
								select="$string:eol"/>
				<xsl:with-param name="replace"
								select="
					 concat($string:eol,
							$string:nbsp,$string:nbsp)"/>
				<xsl:with-param name="input">
					<xsl:value-of select="concat($eol,$text,' ',$eol,'-->')"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="node()|@*"
				  mode="string:text">
        <xsl:if test="normalize-space(translate(.,'&#9;',' '))">
			<xsl:call-template name="string:replace">
				<xsl:with-param name="input">
					<xsl:call-template name="string:deflate"/>
				</xsl:with-param>
				<xsl:with-param name="find">
					<a>&lt;</a>
					<c>&amp;</c>
					<xsl:if test="count(.|../@*)=count(../@*)">
						<d>"</d>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="replace">
					<a>&amp;lt;</a>
					<c>&amp;amp;</c>
					<d>&amp;quot;</d>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>