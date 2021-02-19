class JSON
{
	/**
	* Method: parse
	*     Parses a JSON string into an AHK value
	* Syntax:
	*     value := JSON.parse( text [, reviver ] )
	* Parameter(s):
	*     value      [retval] - parsed value
	*     text    [in, ByRef] - JSON formatted string
	*     reviver   [in, opt] - function object, similar to JavaScript's
	*                           JSON.parse() 'reviver' parameter
	*/

	class parse extends JSON.Functor
	{
		call(self, ByRef text, reviver:="")
		{
			this.rev := isObject(reviver) ? reviver : false
			; Object keys(and array indices) are temporarily stored in arrays so that
			; we can enumerate them in the order they appear in the document/text instead
			; of alphabetically. Skip if no reviver function is specified.
			this.keys := this.rev ? {} : false

			static quot := chr(34), bashq := "\" . quot
				, json_value := quot . "{[01234567890-tfn"
				, json_value_or_array_closing := quot . "{[]01234567890-tfn"
				, object_key_or_object_closing := quot . "}"

			key := ""
			is_key := false
			root := {}
			stack := [root]
			next := json_value
			pos := 0

			while ((ch := subStr(text, ++pos, 1)) != "") {
				if inStr(" `t`r`n", ch)
					continue
				if !inStr(next, ch, 1)
					this.parseError(next, text, pos)

				holder := stack[1]
				is_array := holder.IsArray

				if inStr(",:", ch) {
					next := (is_key := !is_array && ch == ",") ? quot : json_value

				} else if inStr("}]", ch) {
					objRemoveAt(stack, 1)
					next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"

				} else {
					if inStr("{[", ch) {
					; Check if Array() is overridden and if its return value has
					; the 'IsArray' property. If so, Array() will be called normally,
					; otherwise, use a custom base object for arrays
						static json_array := func("Array").isBuiltIn || ![].IsArray ? {IsArray: true} : 0

					; sacrifice readability for minor(actually negligible) performance gain
						(ch == "{")
							? ( is_key := true
							  , value := {}
							  , next := object_key_or_object_closing )
						; ch == "["
							: ( value := json_array ? new json_array : []
							  , next := json_value_or_array_closing )

						ObjInsertAt(stack, 1, value)

						if (this.keys)
							this.keys[value] := []

					} else {
						if (ch == quot) {
							i := pos
							while (i := inStr(text, quot,, i+1)) {
								value := strReplace(subStr(text, pos+1, i-pos-1), "\\", "\u005c")

								static tail := A_AhkVersion<"2" ? 0 : -1
								if (subStr(value, tail) != "\")
									break
							}

							if (!i)
								this.parseError("'", text, pos)

							  value := strReplace(value,  "\/",  "/")
							, value := strReplace(value, bashq, quot)
							, value := strReplace(value,  "\b", "`b")
							, value := strReplace(value,  "\f", "`f")
							, value := strReplace(value,  "\n", "`n")
							, value := strReplace(value,  "\r", "`r")
							, value := strReplace(value,  "\t", "`t")

							pos := i ; update pos

							i := 0
							while (i := inStr(value, "\",, i+1)) {
								if !(subStr(value, i+1, 1) == "u")
									this.parseError("\", text, pos - strLen(subStr(value, i+1)))

								uffff := Abs("0x" . subStr(value, i+2, 4))
								if (A_IsUnicode || uffff < 0x100)
									value := subStr(value, 1, i-1) . chr(uffff) . subStr(value, i+6)
							}

							if (is_key) {
								key := value, next := ":"
								continue
							}

						} else {
							value := subStr(text, pos, i := regExMatch(text, "[\]\},\s]|$",, pos)-pos)

							static number := "number", integer :="integer"
							if value is %number%
							{
								if value is %integer%
									value += 0
							}
							else if (value == "true" || value == "false")
								value := %value% + 0
							else if (value == "null")
								value := ""
							else
							; we can do more here to pinpoint the actual culprit
							; but that's just too much extra work.
								this.parseError(next, text, pos, i)

							pos += i-1
						}

						next := holder==root ? "" : is_array ? ",]" : ",}"
					} ; If inStr("{[", ch) { ... } else

					is_array? key := objPush(holder, value) : holder[key] := value

					if (this.keys && this.keys.hasKey(holder))
						this.keys[holder].Push(key)
				}

			} ; while ( ... )

			return this.rev ? this.walk(root, "") : root[""]
		}

		parseError(expect, ByRef text, pos, len:=1)
		{
			static quot := chr(34), qurly := quot . "}"

			line := strSplit(subStr(text, 1, pos), "`n", "`r").length()
			col := pos - inStr(text, "`n",, -(strLen(text)-pos+1))
			msg := format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
			,     (expect == "")     ? "Extra data"
				: (expect == "'")    ? "Unterminated string starting at"
				: (expect == "\")    ? "Invalid \escape"
				: (expect == ":")    ? "Expecting ':' delimiter"
				: (expect == quot)   ? "Expecting object key enclosed in double quotes"
				: (expect == qurly)  ? "Expecting object key enclosed in double quotes or object closing '}'"
				: (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
				: (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
				: inStr(expect, "]") ? "Expecting JSON value or array closing ']'"
				:                      "Expecting JSON value(string, number, true, false, null, object or array)"
			, line, col, pos)

			static offset := A_AhkVersion<"2" ? -3 : -4
			throw Exception(msg, offset, subStr(text, pos, len))
		}

		walk(holder, key)
		{
			value := holder[key]
			if isObject(value) {
				for i, k in this.keys[value] {
					; check if objhasKey(value, k) ??
					v := this.walk(value, k)
					if (v != JSON.Undefined)
						value[k] := v
					else
						objDelete(value, k)
				}
			}
			return this.rev.call(holder, key, value)
		}
	}


	/**
	* Method: stringify
	*     Converts an AHK value into a JSON string
	* Syntax:
	*     str := JSON.stringify( value [, replacer, space ] )
	* Parameter(s):
	*     str        [retval] - JSON representation of an AHK value
	*     value          [in] - any value(object, string, number)
	*     replacer  [in, opt] - function object, similar to JavaScript's
	*                           JSON.stringify() 'replacer' parameter
	*     space     [in, opt] - similar to JavaScript's JSON.stringify()
	*                           'space' parameter
	*/
	class stringify extends JSON.Functor
	{
		call(self, value, replacer:="", space:="")
		{
			this.rep := isObject(replacer) ? replacer : ""

			this.gap := ""
			if (space) {
				static integer := "integer"
				if space is %integer%
					Loop, % ((n := Abs(space))>10 ? 10 : n)
						this.gap .= " "
				else
					this.gap := subStr(space, 1, 10)

				this.indent := "`n"
			}

			return this.Str({"": value}, "")
		}

		Str(holder, key)
		{
			value := holder[key]

			if (this.rep)
				value := this.rep.call(holder, key, objhasKey(holder, key) ? value : JSON.Undefined)

			if isObject(value) {
			; Check object type, skip serialization for other object types such as
			; ComObject, Func, BoundFunc, FileObject, RegExMatchObject, Property, etc.
				static type := A_AhkVersion<"2" ? "" : func("Type")
				if (type ? type.call(value) == "Object" : objGetCapacity(value) != "") {
					if (this.gap) {
						stepback := this.indent
						this.indent .= this.gap
					}

					is_array := value.IsArray
					; Array() is not overridden, rollback to old method of
					; identifying array-like objects. Due to the use of a for-loop
					; sparse arrays such as '[1,,3]' are detected as objects({}).
					if (!is_array) {
						for i in value
							is_array := i == A_Index
						until !is_array
					}

					str := ""
					if (is_array) {
						Loop, % value.length() {
							if (this.gap)
								str .= this.indent

							v := this.Str(value, A_Index)
							str .= (v != "") ? v . "," : "null,"
						}
					} else {
						colon := this.gap ? ": " : ":"
						for k in value {
							v := this.Str(value, k)
							if (v != "") {
								if (this.gap)
									str .= this.indent

								str .= this.quote(k) . colon . v . ","
							}
						}
					}

					if (str != "") {
						str := rTrim(str, ",")
						if (this.gap)
							str .= stepback
					}

					if (this.gap)
						this.indent := stepback

					return is_array ? "[" . str . "]" : "{" . str . "}"
				}

			} else ; is_number ? value : "value"
				return objGetCapacity([value], 1)=="" ? value : this.quote(value)
		}

		quote(string)
		{
			static quot := chr(34), bashq := "\" . quot

			if (string != "") {
				  string := strReplace(string,  "\",  "\\")
				; , string := strReplace(string,  "/",  "\/") ; optional in ECMAScript
				, string := strReplace(string, quot, bashq)
				, string := strReplace(string, "`b",  "\b")
				, string := strReplace(string, "`f",  "\f")
				, string := strReplace(string, "`n",  "\n")
				, string := strReplace(string, "`r",  "\r")
				, string := strReplace(string, "`t",  "\t")

				static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
				while regExMatch(string, rx_escapable, m)
					string := strReplace(string, m.Value, format("\u{1:04x}", ord(m.Value)))
			}

			return quot . string . quot
		}
	}

	class test extends JSON.Functor
	{
		call(self, value:="")
		{
			if (isObject(value) || value == ""){
				return false
			}
			try {
				JSON.parse(value)
			} catch error {
				return false
			}
			return true
		}
	}


	/**
	* Property: Undefined
	*     Proxy for 'undefined' type
	* Syntax:
	*     undefined := JSON.Undefined
	* Remarks:
	*     For use with reviver and replacer functions since AutoHotkey does not
	*     have an 'undefined' type. Returning blank("") or 0 won't work since these
	*     can't be distnguished from actual JSON values. This leaves us with objects.
	*     Replacer() - the caller may return a non-serializable AHK objects such as
	*     ComObject, Func, BoundFunc, FileObject, RegExMatchObject, and Property to
	*     mimic the behavior of returning 'undefined' in JavaScript but for the sake
	*     of code readability and convenience, it's better to do 'return JSON.Undefined'.
	*     Internally, the property returns a ComObject with the variant type of VT_EMPTY.
	*/
	Undefined[]
	{
		get {
			static empty := {}, vt_empty := ComObject(0, &empty, 1)
			return vt_empty
		}
	}

	class Functor
	{
		__call(method, ByRef arg, args*)
		{
			; When casting to call(), use a new instance of the "function object"
			; so as to avoid directly storing the properties(used across sub-methods)
			; into the "function object" itself.
			if isObject(method)
				return (new this).call(method, arg, args*)
			else if (method == "")
				return (new this).call(arg, args*)
		}
	}
}
