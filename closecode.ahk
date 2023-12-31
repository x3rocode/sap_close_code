﻿#Singleinstance Force

#Hotstring EndChars `n

:B0 C1:for::`r`n응애

;hotstrings("i)forf(.*).\n", "close") ; type 'OMG' in any case, upper, lower or mixed

return

hotstrings(k, a = "")
{
	static z, m = "*~$", s, t, w = 2000, sd, d = "Left,Right,Up,Down,Home,End,RButton,LButton"
	global $
	If z = ; init
	{
		RegRead, sd, HKCU, Control Panel\International, sDecimal
		Loop, 94
		{
			c := Chr(A_Index + 32)
			If A_Index not between 33 and 58
				Hotkey, %m%%c%, __hs
		}
		e = 0,1,2,3,4,5,6,7,8,9,Dot,Div,Mult,Add,Sub,Enter
		Loop, Parse, e, `,
			Hotkey, %m%Numpad%A_LoopField%, __hs
		e = BS,Space,Enter,Return,Tab,%d%
		Loop, Parse, e, `,
			Hotkey, %m%%A_LoopField%, __hs
		z = 1
		msgbox, %__hs%
	}
	If (a == "" and k == "") ; poll
	{
		StringTrimLeft, q, A_ThisHotkey, StrLen(m)
		If q = BS
		{
			If (SubStr(s, 0) != "}")
				StringTrimRight, s, s, 1
		}
		Else If q in %d%
			s = 
		Else
		{
			If q = Space
				q := " "
			Else If q = Tab
				q := "`t"
			Else If q in Enter,Return,NumpadEnter
				q := "`n"
			Else If (RegExMatch(q, "Numpad(.+)", n))
			{
				q := n1 == "Div" ? "/" : n1 == "Mult" ? "*" : n1 == "Add" ? "+" : n1 == "Sub" ? "-" : n1 == "Dot" ? sd : ""
				If n1 is digit
					q = %n1%
			}
			Else If (StrLen(q) != 1)
				q = {%q%}
			Else If (GetKeyState("Shift") ^ GetKeyState("CapsLock", "T"))
				StringUpper, q, q
			s .= q
		}
		Loop, Parse, t, `n ; check
		{
			StringSplit, x, A_LoopField, `r
			If (RegExMatch(s, x1 . "$", $)) ; match
			{
				StringLen, l, $
				StringTrimRight, s, s, l
				SendInput, {BS %l%}
				If (IsLabel(x2))
					Gosub, %x2%
				Else
				{
					Transform, x0, Deref, %x2%
					SendInput, %x0%
				}
			}
		}
		If (StrLen(s) > w)
			StringTrimLeft, s, s, w // 2
	}
	Else ; assert
	{
		StringReplace, k, k, `n, \n, All ; normalize
		StringReplace, k, k, `r, \r, All
		Loop, Parse, t, `n
		{
			l = %A_LoopField%
			If (SubStr(l, 1, InStr(l, "`r") - 1) == k)
				StringReplace, t, t, `n%l%
		}
		If a !=
			msgbox, %a%
			;t = %t%`n%k%`r%a%
			t = %t%`n%k%`r%a%
	}
	Return
	__hs: ; event
	hotstrings("", "")
	Return
}