# JSON.ahk

Works on both AutoHotkey _v1.1_ and _v2.0a_

#### [JSON](http://json.org/) lib for [AutoHotkey](http://ahkscript.org/)

Requires the latest version of AutoHotkey _(v1.1+ or v2.0-a+)_

-----



### Installation
Use `#Include json.ahk` or copy into a [function library folder](http://ahkscript.org/docs/Functions.htm#lib) and use `#Include <JSON>`.


## API
### .parse()
Parses a JSON string into an AHK value.

#### Syntax:
```autohotkey
value := JSON.parse(text [, reviver ])
```

#### Return Value:
An AutoHotkey value _(object, string, number)_

#### Parameter(s):
 * **text** - JSON formatted string
 * **reviver** [optional] - function object, prescribes how the value originally produced by parsing is transformed, before being returned. Similar to JavaScript's `JSON.parse()` _reviver_ parameter

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
 * **value** - AutoHotkey value _(object, string, number)_
 * **replacer** [optional] - function object, alters the behavior of the stringification process. Similar to JavaScript's `JSON.stringify()` _replacer_ parameter
 * **space** [optional] -if _space_ is a non-negative integer or string, then JSON array elements and object members will be pretty-printed with that indent level. Blank( ``""`` ) _(the default)_ or ``0`` selects the most compact representation. Using a positive integer _space_ indents that many spaces per level, this number is capped at 10 if it's larger than that. If _space_ is a string (such as ``"`t"``), the string _(or the first 10 characters of the string, if it's longer than that)_ is used to indent each level


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
