#Requires AutoHotkey v2.0
#Include closecode2.ahk
#SingleInstance Force

RegExHotstring("\W*if(.*)\.", call, "B0")
RegExHotstring("\W*loop(.*)\.", call, "B0")
RegExHotstring("\W*case(.*)\.", call, "B0")

call(match) {
    ctype:=''
    ul:=''
    
    ctype:= StrSplit(Ltrim(match[0]), A_Space)
    ul:= isUpper(ctype[1]) ? "{:U}" : "{:L}"
    str:= "`r`n`b`bend" ctype[1] "."
    
    Send(format(ul, str))
    Send("{Up}")

    if(ctype[1] == format(ul, 'case'))
        Send(format(ul, "when`s"))

    return
}
