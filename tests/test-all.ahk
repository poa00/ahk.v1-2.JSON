#Include %A_ScriptDir%\..\export.ahk
#Include %A_ScriptDir%\..\node_modules
#Include unit-testing.ahk\export.ahk
#NoTrayIcon
#SingleInstance, force
SetBatchLines, -1

assert := new unittesting()

assert.group("parse")
assert.label("simple array")
assert.test(JSON.parse("[1, 2, 3]"), [1, 2, 3])

assert.label("keyed object")
; assert.test(JSON.parse("{""one"": 1, ""two"": 2, ""three"": 3}"), {"one": 1, "two": 2, "three": 3})


assert.group("test")
assert.label("invalid json")
assert.false(JSON.test("[[[,,,,""[]"))
assert.false(JSON.test("[1, 2, 3]]"))
assert.false(JSON.test("[{}{{{]"))
assert.false(JSON.test("[[}}]"))

assert.label("valid json")
assert.true(JSON.test("[1, 2, 3]"))


assert.fullReport()
ExitApp
