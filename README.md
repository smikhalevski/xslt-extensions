# XSLT Extensions

Complex datetime and string operations for XSLT 1.0.

## Datetime
[RFC 3339](http://tools.ietf.org/html/rfc3339) compliant format `[-|+]yyyy[-MM[-dd(T|_)[hh:mm[:ss[.μ]][Z|(+|-)hh:mm]]]]` is used.

Templates are available in namespace `urn:ehony:date`.

### Templates

#### `timestamp($date-time)`

Calculates difference in milliseconds between midnight 1970-01-01 and provided date. Timestamp is UTC compliant: `Date.setTime` would set valid UTC date in JavaScript. In case invalid format is used then empty string is returned.

Takes optional date-time string parameter `$date-time`, by default equals to value of current node.

#### `date-time($timestamp)`

Converts timestamp in millisecond to RFC 3339 compliant UTC date-time string in format `[-]yyyy-MM-ddThh:mm:ss.μμμZ`. If provided timestamp cannot be converted to number, empty string is returned.
      
Takes optional signed integer parameter `$timestamp` representing millisecond date offset from midnight 1970-01-01, by default equals to value of current node.

#### `set-timezone($date-time, $offset)`

Changes provided date-time string to match given timezone and outputs string in format: `[-]yyyy-MM-ddThh:mm:ss.μμμ(Z|(+|-)hh:mm)|""`. When invalid format is provided empty string is returned.

Optional date-time string parameter `$date-time` which by default equals to value of current node.

Optional `$offset` parameter describing desired timezone offset to shift date-time to. Required format is RFC 3339 compliant timezone: `[[+|-]hh[:mm]|Z]`. When Z or blank line is provided UTC time is returned.

#### `duration($msec, $format)`

Converts provided milliseconds to a human readable form in requested format: `PdDThHmMs.μμμS|dDhh:mm:ss.μ|""`.

Optional parameter `$msec` sets number of μsec, by default equals to value of current node.

Optional parameter `$format` sets [name of the format](http://www.w3.org/TR/xmlschema-2/#duration).


