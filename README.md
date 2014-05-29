# XSLT Extensions

Complex date-time and string operations for XSLT 1.0.

## Contents

1. [Datetime](#datetime)
    1. [`timestamp`](#timestamp)
    2. [`date-time`](#date-time)
    3. [`set-timezone`](#set-timezone)
    4. [`duration`](#duration)
2. [String](#string)
    1. [`explode`](#explodeinput-delimiter)
    2. [`replace`](#replaceinput-search-replace)
    3. [`repeat`](#repeatinput-count)
    4. [`indent`](#indentinput-count)
    5. [`deflate`](#deflateinput-condense)
    6. [`xml`](#xmlnodeset)
3. [License](#license)

## Datetime
Templates are available in namespace `urn:ehony:date` further referenced as `date`. [RFC 3339](http://tools.ietf.org/html/rfc3339) compliant format is used: `[-|+]yyyy[-MM[-dd(T|_)[hh:mm[:ss[.μ]][Z|(+|-)hh:mm]]]]`. Following date-times are valid: `2014`, `2014-12-31 09:56`, `2014-12-31T09:56:48.872+04:00`.

### `timestamp`

Calculates difference in milliseconds between midnight 1970-01-01 and provided date-time. Timestamp is UTC compliant: for example, `Date.setTime` would set valid UTC date in JavaScript. In case invalid format is used then empty string is returned.

**Parameters**<br/>
* `date-time` Optional RFC-compliant date-time string. By default equals to value of current node.

```xslt
<xsl:call-template name="date:timestamp">
   <xsl:with-param name="date-time" value="2014-05-29 12:09:41"/>
</xsl:call-template>
```
Output: `1401379781`

### `date-time`

Converts timestamp from millisecond to RFC 3339 compliant UTC date-time string in format `[-]yyyy-MM-ddThh:mm:ss.μμμZ`. If provided timestamp cannot be converted to number, empty string is returned.

**Parameters**<br/>
* `timestamp` Optional signed integer, representing millisecond date offset from midnight 1970-01-01. By default equals to value of current node.

```xslt
<xsl:call-template name="date:date-time">
   <xsl:with-param name="timestamp" value="1401379781"/>
</xsl:call-template>
```
Output: `2014-05-29T12:09:41Z`

### `set-timezone`

Changes provided date-time string to match given timezone and outputs string in format: `[-]yyyy-MM-ddThh:mm:ss.μμμ(Z|(+|-)hh:mm)|""`. When invalid format is provided empty string is returned.

**Parameters**<br/>
* `date-time` Optional RFC-compliant date-time string. By default equals to value of current node.
* `offset` Optional timezone offset to shift date-time to. Required format is RFC 3339 compliant timezone: `[[+|-]hh[:mm]|Z]`. When equals to `Z` or blank line then UTC time is returned.

```xslt
<xsl:call-template name="date:set-timezone">
   <xsl:with-param name="date-time" value="2014-05-29 12:09:41"/>
   <xsl:with-param name="offset" value="+04:00"/>
</xsl:call-template>
```
Output: <code>2014-05-<b>30</b>T<b>04</b>:09:41<b>+04:00</b></code>

### `duration`

Converts provided milliseconds to a human readable form in requested [format](http://www.w3.org/TR/xmlschema-2/#duration).

**Parameters**<br/>
* `msec` Optional number of μsec. By default equals to value of current node. For empty or non-integer value nothing is output.
* `format` Optional name of the required format. For `xsd:duration` output format would be `PdDThHmMs.μμμS`, otherwise `dDhh:mm:ss.μ`.

```xslt
<xsl:call-template name="date:duration">
   <xsl:with-param name="msec" value="93312648600"/>
</xsl:call-template>
```
Output: `5D03:10:00.0`

## String

Templates are available in namespace `urn:ehony:string`.

### `explode(input, delimiter)`

Analogue of [explode](http://www.php.net/manual/en/function.explode) function in PHP. Returns nodeset where each element is a substring of string formed by splitting input on boundaries formed by the string delimiter.
	  
Parameter $input [optional|.] input string.

Parameter $delimiter [optional|""] boundary string. Empty value causes string to be splitted into separate characters.

### `replace(input, search, replace)`

Analogue of [str_replace](http://php.net/manual/en/function.str-replace) function in PHP. Replaces all occurences of searched string with the given value.

Parameter $input [optional|.] string to search in.

Parameter $search [required] character sequence to search for. If omitted then no changes are made to input.

Parameter $replace [optional|""] string to substitute.

### `repeat(input, count)`

Analogue of [str_repeat](http://php.net/manual/en/function.str-repeat) in PHP. Repeats provided string given number of times.

Parameter $input [optional|.] string to repeat.

Parameter $count [optional|1] integer number of repeats.

### `indent(input, count)`

### `deflate(input, condense)`

### `xml(nodeset)`

Converts any given nodeset into preformatted text by exploiting local templates with `string:(xml|text)}`

Note: Opera treats space and eol-filled blocks as text nodes, but stylesheet has to preserve unity among parses from different vendors so all match-based templates check normalized content for emptiness.
	  
Parameter $nodeset [optional|.] nodeset to format source of.

## License

The code is available under [MIT licence](LICENSE.txt).
