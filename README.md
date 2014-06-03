# XSLT Extensions

Date-time and string extensions for XSLT 1.0 [on the client](http://www.w3schools.com/xsl/xsl_client.asp).

Compatible browser versions starting from Safari 5, Firefox 3, Internet Explorer 8, Chrome and Opera.

## Contents

1. [Datetime](#datetime)
    1. [`timestamp`](#timestamp)
    2. [`date-time`](#date-time)
    3. [`set-timezone`](#set-timezone)
    4. [`duration`](#duration)
2. [String](#string)
    1. [`explode`](#explode)
    2. [`replace`](#replace)
    3. [`repeat`](#repeat)
    4. [`indent`](#indent)
    5. [`deflate`](#deflate)
    6. [`xml`](#xml)
3. [License](#license)

## [Datetime](date.xslt)

Templates are available in namespace `urn:ehony:date` further referenced as `date`. [RFC 3339][RFC] compliant date format is used: `[-]yyyy[-MM[-dd(T|_)[hh:mm[:ss[.μ]][Z|(+|-)hh:mm]]]]`. Following date-times are valid: `2014`, `2014-12-31 09:56`, `2014-12-31T09:56:48.872+04:00`.

### `timestamp`

Calculates difference in milliseconds between midnight 1970-01-01 and provided date-time. Timestamp is UTC compliant: for example, [`Date.setTime`](http://www.w3schools.com/jsref/jsref_setTime.asp) would set valid UTC date in JavaScript. In case invalid format is used then empty string is returned.

**Parameter**<br/>
* **`date-time`** [RFC][RFC]-compliant date-time string. Optional, by default equals to value of the current node.

```xslt
<xsl:call-template name="date:timestamp">
   <xsl:with-param name="date-time" value="2014-05-29 12:09:41"/>
</xsl:call-template>
```
Output: `1401379781`

### `date-time`

Converts timestamp from milliseconds to [RFC 3339][RFC] compliant UTC-based date-time string in format `[-]yyyy-MM-ddThh:mm:ss.μμμZ`. If provided timestamp cannot be converted to number, empty string is returned.

**Parameter**<br/>
* **`timestamp`** Signed integer, representing millisecond date offset from midnight 1970-01-01. Optional, by default equals to value of current node.

```xslt
<xsl:call-template name="date:date-time">
   <xsl:with-param name="timestamp" value="1401379781"/>
</xsl:call-template>
```
Output: `2014-05-29T12:09:41Z`

### `set-timezone`

Changes provided date-time string to match given timezone and outputs fully qualified [RFC 3339][RFC] string. If invalid format of date-time is provided then empty string is returned.

**Parameters**<br/>
* **`date-time`** [RFC][RFC]-compliant date-time string. Optional, by default equals to value of current node.
* **`offset`** Timezone offset to shift date-time to, in format: `[+|-]hh[:mm]` or `Z`. When equals to `Z` or blank line then UTC time is returned. Optional, `Z` by default.

```xslt
<xsl:call-template name="date:set-timezone">
   <xsl:with-param name="date-time" value="2014-05-29 12:09:41"/>
   <xsl:with-param name="offset" value="+04"/>
</xsl:call-template>
```
Output: <code>2014-05-<b>30</b>T<b>04</b>:09:41<b>+04:00</b></code>

### `duration`

Converts provided milliseconds to a human readable form in requested [format](http://www.w3.org/TR/xmlschema-2/#duration). If provided duration cannot be converted to number, empty string is returned.

**Parameters**<br/>
* **`msec`** Number of milliseconds. Optional, by default equals to value of current node.
* **`format`** Name of the required format. For `xsd:duration` output format would be `PdDThHmMs.μμμS`, otherwise `dDhh:mm:ss.μ`. Namespace `xsd` may be omitted in stylesheet.

```xslt
<xsl:call-template name="date:duration">
   <xsl:with-param name="msec" value="442860"/>
</xsl:call-template>
```
Output: `5D03:10:00.0`

## [String](string.xslt)

Templates are available in namespace `urn:ehony:string` further referenced as `string`.

**Compatibility Notice.** This stylesheet uses [`node-set`](http://exslt.org/exsl/functions/node-set/index.html) which is supported in all listed browsers but may be abcent in standalone interpreters.

### `explode`

Returns nodeset where each element is a substring of string formed by splitting input on boundaries formed by the string delimiter. Analogue of [explode](http://www.php.net/manual/en/function.explode) function in PHP.

**Parameters**<br/>
* **`input`** Input string. Optional, by default equals to value of current node.
* **`delimiter`** Boundaries to split input by. To split by multiple delimiters provide a nodeset with arbitarary tags containing text nodes. Omitting this parameter or providing an empty string causes input to be splitted into separate characters.

```xslt
<xsl:call-template name="string:explode">
   <xsl:with-param name="input" value="Jane,Peter;James"/>
   <xsl:with-param name="delimiter">
      <a>,</a>
      <b>;</b>
   </xsl:with-param>
</xsl:call-template>
```
Output (manually formatted):
```xml
<fragment>Jane</fragment>
<fragment>Peter</fragment>
<fragment>James</fragment>
```

### `replace`

Replaces all occurences of searched string with the given value.

**Parameters**<br/>
* **`input`** String to search in. Optional, by default equals to value of current node.
* **`search`** Character sequence to search for. If omitted then no changes are made to input.
* **`replace`** String to substitute, empty by default.

```xslt
<xsl:call-template name="string:replace">
   <xsl:with-param name="input" value="Hello Peter and Robin!"/>
   <xsl:with-param name="search">
      <a>Peter</a>
      <b>Robin</b>
   </xsl:with-param>
   <xsl:with-param name="replace">
      <a>Kevin</a>
      <b>Martha</b>
   </xsl:with-param>
</xsl:call-template>
```
Output: `Hello Kevin and Martha!`

### `repeat`

Repeats provided string given number of times.

**Parameters**<br/>
* **`input`** String to repeat. Optional, by default equals to value of current node.
* **`count`** Integer number of repeats, `1` by default.

```xslt
<xsl:call-template name="string:repeat">
   <xsl:with-param name="input" value="Love"/>
   <xsl:with-param name="count" value="3"/>
</xsl:call-template>
```
Output: `LoveLoveLove`

### `indent`

Adds required nuber of whitespaces before each line of the text.

**Parameters**<br/>
* **`input`** String to indent. Optional, by default equals to value of current node.
* **`count`** Integer number of spaces to indent by, `0` by default.

```xslt
<xsl:call-template name="string:repeat">
   <xsl:with-param name="input"><![CDATA[
Lorem ipsum dolor sit amet,
consectetur adipisicing elit.
]]><xsl:with-param/>
   <xsl:with-param name="count" value="4"/>
</xsl:call-template>
```
Output (introduced spaces are shown as <code>&middot;</code> symbol):
<pre>
&middot;&middot;&middot;&middot;Lorem ipsum dolor sit amet,
&middot;&middot;&middot;&middot;consectetur adipisicing elit.
</pre>

### `deflate`

Removes excessive space characters from the string preserving line feeds.

**Parameter**<br/>
* **`input`** String to deflate. Optional, by default equals to value of current node.

### `xml`

Converts any given nodeset into preformatted text by exploiting local templates with modes `string:xml` and `string:text`.

**Implementation Considerations.** Opera treats consequent spaces and line-feeds as text nodes, while other browsers does not. To preserve unity among parses from different vendors all text content (not attributes) which is blank after normalization is omitted.

**Parameter**<br/>
* **`nodeset`** Nodeset to format source of. Current node, by default.

## License

The code is available under [MIT licence](LICENSE.txt).

[RFC]: http://tools.ietf.org/html/rfc3339
