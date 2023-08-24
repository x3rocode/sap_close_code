#Requires AutoHotkey v2.0




; this send level allows trigger hotstring in same script
SendLevel(1)
RegHook := RegExHk("VI2")
RegHook.NotifyNonText := true
RegHook.VisibleText := false
RegHook.KeyOpt("{Space}{Tab}{Enter}{NumpadEnter}{BackSpace}", "+SN")
RegHook.Start()

RegExHotstring(String, CallBack, Options := "") {
	RegHook.Add(String, CallBack, Options)
}

class RegExHk extends InputHook {
	; stores with RegEx string as key and obj as value
	; "*0" option
	a0 := Map()
	; "*" option
	a := Map()

	; parse options and store in map
	class obj {
		__New(string, call, options) {
			this.call := call
			this.str := string
			this.opt := Map("*", false, "?", false, "B", true, "C", false, "O", false, "T", false)
			loop parse (options) {
				switch A_LoopField {
					case "*", "?", "B", "C", "O", "T":
						this.opt[A_LoopField] := true
					case "0":
						try
							this.opt[temp] := false
						catch
							throw ValueError("Unknown option: " A_LoopField)
					default:
						throw ValueError("Unknown option: " A_LoopField)
				}
				temp := A_LoopField
			}
			this.str := this.opt["?"] ? this.str "$" : "^" this.str "$"
			this.str := this.opt["C"] ? this.str : "i)" this.str
		}
	}

	Add(String, CallBack, Options) {
		info := RegExHk.obj(String, CallBack, Options)
		if (info.opt["*"]) {
			try
				this.a0.Delete(String)
			; end key is always omitted
			info.opt["O"] := true
			this.a[String] := info
		} else {
			try
				this.a.Delete(String)
			this.a0[String] := info
		}
	}

	OnKeyDown := this.keyDown
	keyDown(vk, sc) {
		switch vk {
			case 8:  ; backspace
				Send("{Blind}{vk08 down}")
			case 13:  ;9 tab 13 enter 32  spacebar
				; clear input if not match
				if (!this.match(this.a0,
					SubStr(this.Input, 1, StrLen(this.Input) - 1),
					(*) => Send("{Blind}{vk" Format("{:02x}", vk) " down}"))) {
					this.Stop()
					this.Start()
				}
            case 9, 32:
                Send("{Blind}{vk" Format("{:02x}", vk) " down}")
			case 160, 161:
				; do nothing on shift key
			default:
				; clear input when press non-text key
				this.Stop()
				this.Start()
		}
	}

	OnKeyUp := this.keyUp
	keyUp(vk, sc) {
		switch vk {
			case 8, 9, 13, 32:
				Send("{Blind}{vk" Format("{:02x}", vk) " up}")
		}
	}

	OnChar := this.char
	char(c) {
		blind := StrLen(c) > 1 ? "" : "{Blind}"
		loop parse c {
			c := A_LoopField
			vk := GetKeyVK(GetKeyName(c))
			switch vk {
				case 9, 13, 32:
					return
			}
			; if capslock is on, convert to lower case
			GetKeyState("CapsLock", "T") ? c := StrLower(c) : 0
			; no need to clear input
			this.match(this.a, , (*) => Send(blind "{" c " down}"), 1, c)
			Send(blind "{" c " up}")
		}
	}

	match(map, input := this.Input, defer := (*) => 0, a := 0, c := 0) {
		; debug use
		; ToolTip(this.Input)
		if (!map.Count) {
			defer()
			return false
		}
		; loop through each strings and find the first match
		for , obj in map {
			str := obj.str
			call := obj.call
			opt := obj.opt
			start := RegExMatch(input, str, &match)
			; if match, send replace or call function
			if (start) {
				if (opt["B"])
					Send("{BS " match.Len[0] - a "}")
				if (call is String) {
					this.Stop()
					if (opt["T"]) {
						SendText(RegExReplace(SubStr(input, start), str, call))
					} else {
						Send(RegExReplace(SubStr(input, start), str, call))
					}
					if (!opt["O"])
						defer()
					this.Start()
				} else if (call is Func) {
					Hotstring(":*:" c, (*) => 0, "On")
					this.Stop()
					call(match)
					this.Start()
					Hotstring(":*:" c, (*) => 0, "Off")
				} else
					throw TypeError('CallBack type error `nCallBack should be "Func" or "String"')
				return true
			}
		}
		defer()
		return false
	}
}