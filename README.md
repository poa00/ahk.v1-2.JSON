# JSON.ahk

#### [JSON](http://json.org/) lib for [AutoHotkey](http://ahkscript.org/)

Works on both _v1.1_ and _v2.0a_

Requires the latest version of AutoHotkey _(v1.1+ or v2.0-a+)_

-----



## Installation
Use `#Include json.ahk` or copy into a [function library folder](http://ahkscript.org/docs/Functions.htm#lib) and use `#Include <JSON>`.


## API
### .parse()
Parses a JSON string into an AHK value.

#### Syntax:
```autohotkey
value := JSON.parse(text [, reviver ])
```

#### Return Value:
value (object, string, number)

#### Parameter(s):
 * **text** - JSON formatted string
 * **reviver** [optional] - function object, prescribes how the value originally produced by parsing is transformed, before being returned. Similar to JavaScript's `JSON.parse()` reviver parameter

- - -

### .stringify()
Converts an AHK value into a JSON string.

#### Syntax:
```autohotkey
str := JSON.stringify(value, [, replacer, space ])
```

#### Return Value:
A JSON formatted string

#### Parameter(s):
 * **value** - (object, string, number)
 * **replacer** [optional] - function object, alters the behavior of the stringification process. Similar to JavaScript's `JSON.stringify()` replacer parameter
 * **space** [optional] -if space is a non-negative integer or string, then JSON array elements and object members will be pretty-printed with that indent level. Blank( ``""`` ) (the default) or ``0`` selects the most compact representation. Using a positive integer space indents that many spaces per level, this number is capped at 10 if it's larger than that. If space is a string (such as ``"`t"``), the string (or the first 10 characters of the string, if it's longer than that) is used to indent each level


### .test()
tests if a string is valid json or not.

#### Syntax:
```autohotkey
JSON.test(value)
```

#### Return Value:
`true` if the string is interpreted as valid json, else `false`

#### Parameter(s):
 * **value** - the string value to be tested for validity
