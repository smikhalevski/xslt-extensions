# XSLT Extensions

Complex datetime and string operations for XSLT 1.0.

## Contents

1. [Datetime](#datetime)
    1. [`timestamp(date-time)`](#timestampdate-time)
    2. [`date-time(timestamp)`](#date-timetimestamp)
    3. [`set-timezone(date-time, offset)`](#set-timezonedate-time-offset)
    4. [`duration(msec, format)`](#durationmsec-format)
2. [String](#string)
    1. [`explode(input, delimiter)`](#explodeinput-delimiter)
    2. [`replace(input, search, replace)`](#replaceinput-search-replace)
    3. [`repeat(input, count)`](#repeatinput-count)
    4. [`indent(input, count)`](#indentinput-count)
    5. [`deflate(input, condense)`](#deflateinput-condense)
    6. [`xml(nodeset)`](#xmlnodeset)
3. [License](#license)

## Datetime
[RFC 3339](http://tools.ietf.org/html/rfc3339) compliant format `[-|+]yyyy[-MM[-dd(T|_)[hh:mm[:ss[.μ]][Z|(+|-)hh:mm]]]]` is used.

Templates are available in namespace `urn:ehony:date`.

### `timestamp(date-time)`

Calculates difference in milliseconds between midnight 1970-01-01 and provided date. Timestamp is UTC compliant: `Date.setTime` would set valid UTC date in JavaScript. In case invalid format is used then empty string is returned.

Takes optional date-time string parameter `$date-time`, by default equals to value of current node.

### `date-time(timestamp)`

Converts timestamp in millisecond to RFC 3339 compliant UTC date-time string in format `[-]yyyy-MM-ddThh:mm:ss.μμμZ`. If provided timestamp cannot be converted to number, empty string is returned.
      
Takes optional signed integer parameter `$timestamp` representing millisecond date offset from midnight 1970-01-01, by default equals to value of current node.

### `set-timezone(date-time, offset)`

Changes provided date-time string to match given timezone and outputs string in format: `[-]yyyy-MM-ddThh:mm:ss.μμμ(Z|(+|-)hh:mm)|""`. When invalid format is provided empty string is returned.

Optional date-time string parameter `$date-time` which by default equals to value of current node.

Optional `$offset` parameter describing desired timezone offset to shift date-time to. Required format is RFC 3339 compliant timezone: `[[+|-]hh[:mm]|Z]`. When Z or blank line is provided UTC time is returned.

### `duration(msec, format)`

Converts provided milliseconds to a human readable form in requested format: `PdDThHmMs.μμμS|dDhh:mm:ss.μ|""`.

Optional parameter `$msec` sets number of μsec, by default equals to value of current node.

Optional parameter `$format` sets [name of the format](http://www.w3.org/TR/xmlschema-2/#duration).

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
