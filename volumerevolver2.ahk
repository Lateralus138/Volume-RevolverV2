;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Volume Revolver V2                                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Directives                                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RunAsAdmin((!A_IsAdmin?A_ScriptFullPath:0),A_Args[1])
#SingleInstance,Force
SetBatchLines,-1
SetWorkingDir,%A_ScriptDir%
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Vars                                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tTime:=(isNum(A_Args[1] Or (A_Args[1]=="0")))?A_Args[1]:1500
dMsg:="Disable at &Start Up"
eMsg:="Enable at &Start Up"
s:=new Sound
vR:="Volume Revolver"
Class Color {
	__New(){
		this.black:="0x000000"
		this.dark:="0x373737"
		this.shade:="0x171717"
		this.red:="0xF03A17"
		this.blue:="0x0066CC"
		this.light:="0xC8C8C8"
		this.hilight:="0xE8E8E8"
		this.white:="0xFFFFFF"
	}
}
c:=New Color
modS:=(0x200+0x800000) ; +0x1000+0x400000+
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Menu                                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Menu,Tray,NoStandard
initMenu()
For wMsg, wNum in 	{	"WM_LBUTTONDOWN":0x201,	"WM_LBUTTONUP":0x202	}
	OnMessage(wNum,wMsg)
wNum:=wMsg:=""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cleanup                                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mem.emptyMem()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hotkeys                                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^WheelUp::SetTimer,s1,-1
^WheelDown::SetTimer,s2,-1
+WheelUp::SetTimer,s3,-1
+WheelDown::SetTimer,s4,-1
!WheelUp::
	If s.set(1,,"Mute") {
		If tTime {
			ToolTip,Mute is On
			SetTimer,EndToolTip,% tTime
		}
		Mem.emptyMem()
	}
Return
!WheelDown::
	If s.set(0,,"Mute") {
		If tTime {
			ToolTip,Mute is Off
			SetTimer,EndToolTip,% tTime 
		}
		Mem.emptyMem()
	}
Return
!MButton::
	If s.set(-1,,"Mute") {
		If tTime {
			ToolTip,% s.get(,"Mute")?"Mute is On":"Mute is Off"
			SetTimer,EndToolTip,% tTime
		}
		Mem.emptyMem()
	}
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions                                                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MouseOver(x1,y1,x2,y2,coordmode:="Screen"){
	CoordMode,Mouse,%coordmode%
	MouseGetPos,_x,_y
	CoordMode,Mouse,Screen
	Return InBounds(_x,_y,x1,y1,x2,y2) 
}
InBounds(x,y,bounds*){
	Return 		(bounds.MaxIndex()=4)
			?	(x>=bounds[1]
				AND x<=bounds[3]
				AND y>=bounds[2]
				AND y<=bounds[4])
			:	0
}
startUp(){
	Global
	If isEnabled() {
		RegDelete,HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run,%vR%
		initMenu()
	}	Else	{
		RegWrite,REG_SZ,HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run,%vR%,%A_ScriptFullPath%
		initMenu()
	}
	Mem.emptyMem()
}
initMenu(){
	Global
	Menu,Tray,DeleteAll
	Menu,Tray,Add,Volume +10,s3
	Menu,Tray,Icon,Volume +10,shell32.dll,247
	Menu,Tray,Add,Volume +1,s1
	Menu,Tray,Icon,Volume +1,shell32.dll,247
	Menu,Tray,Add,Volume -1,s2
	Menu,Tray,Icon,Volume -1,shell32.dll,248
	Menu,Tray,Add,Volume -10,s4
	Menu,Tray,Icon,Volume -10,shell32.dll,248
	Menu,Tray,Add,Toggle &Mute,s5
	Menu,Tray,Icon,Toggle &Mute,SndVol.exe,% (s.get(,"Mute")?2:3)
	Menu,Tray,Add
	Menu,Tray,Add,% (A_IsSuspended?"Enable":"Disable") . " Hot&keys",toggleHotkeys
	Menu,Tray,Icon,% (A_IsSuspended?"Enable":"Disable") . " Hot&keys",msctf.dll,% A_IsSuspended?24:20   ;input.dll,2
	Menu,Tray,Add,% isEnabled()?dMsg:eMsg,startUp
	Menu,Tray,Icon,% isEnabled()?dMsg:eMsg,% A_IsCompiled?A_ScriptFullPath:"SndVol.exe"
	Menu,Tray,Add,&Help,Help
	Menu,Tray,Icon,&Help,shell32.dll,24
	Menu,Tray,Add,E&xit,Exit
	Menu,Tray,Icon,E&xit,imageres.dll,94
}
toggleHotkeys(){
	Suspend,Toggle
	initMenu()
}
isNum(num){
	Return (num+0)
}
isEnabled(){
	Global
	Local isEnabled
	RegRead,isEnabled,HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run,%vR%
	Return isEnabled
}
helpWindow(){
	Global
	Gui,Destroy
	Gui,Margin,0,0
	Gui,-Caption +ToolWindow +Border +AlwaysOnTop
	Gui,Color,% c.white,% c.dark
	Gui,Font,% "s14 q5 c" c.white,Segoe UI
	GuiButton(vR " Help","hTxtV","hPrgrssV","hButtonHwnd","hBTxtHwnd",,c.black,c.dark,0,0,300,32)
	Gui,Font,% "s10 c" c.dark
	Gui,Add,Text,x8 y+8 w284 +Center,Control the system volume with the mouse wheel and modifier keys (Ctrl,Shift,Alt)
	Gui,Font,% "s13 c" c.red
	Gui,Add,Text,xp y+8 w284 +Center,Hotkeys
	gP:=Func("guiPlus").Bind("+0","p",8,24)
	gE:=Func("guiEquals").Bind("+0","p",9,24)
	Gui,Font,% "s10 c" c.blue
	module("Control","p","+8",89,56,modS)
	guiSection(,"p")
	guiP()
	module("Wheel Up","+0","p",89,24,modS,"")
	guiE()	
	module("Volume +1","+0","p",89,24,modS,"")
	guiSection("s","+8")
	guiP()
	module("Wheel Down","+0","p",89,24,modS,"")
	guiE()
	module("Volume -1","+0","p",89,24,modS,"")
	module("Shift",8,"+16",89,56,modS)
	guiSection(,"p")
	guiP()
	module("Wheel Up","+0","p",89,24,modS,"")
	guiE()
	module("Volume +10","+0","p",89,24,modS,"")
	guiSection("s","+8")
	guiP()
	module("Wheel Down","+0","p",89,24,modS,"")
	guiE()
	module("Volume -10","+0","p",89,24,modS,"")
	module("Alt",8,"+16",89,88,modS)
	guiSection(,"p")
	guiP()
	module("Wheel Up","+0","p",89,24,modS,"")
	guiE()
	module("Mute On","+0","p",89,24,modS,"")
	guiSection("s","+8")
	guiP()
	module("Wheel Down","+0","p",89,24,modS,"")
	guiE()
	module("Mute Off","+0","p",89,24,modS,"")
	guiSection("s","+8")
	guiP()
	module("Click Wheel","+0","p",89,24,modS,"")
	guiE()
	module("Toggle Mute","+0","p",89,24,modS,"")
	Gui,Font,% "c" c.dark
	Gui,Add,Text,Section x8 y+16 w286,	%	"Control" A_Tab "=" A_Tab "Precision Volume Control"
										.	"`nShift" A_Tab "=" A_Tab "Quick Volume Control"
										.	"`nAlt" A_Tab "=" A_Tab "Mute Control"
	t:=incChars(" ",11)
	Gui,Font,% "c" c.dark
	Gui,Add,Link,xs y+16 w286,More of my projects can be found @ <a href="https://lateralus138.github.io/">Github.io</a>
	guiSection(8,"+0",284,8)
	If A_IsCompiled
		Gui,Add,Picture,x4 y4 w24 h24 +BackgroundTrans Icon1,%A_ScriptFullPath%
	Gui,Add,Picture,x272 y4 w24 h24 Icon94 +BackgroundTrans,imageres.dll
	Gui,Show,AutoSize,%vR%
	Gui,+LastFound
	A_GuiId:=WinExist()
	Mem.emptyMem()
}
module(mode,x,y,w,h,style,sect:="Section"){
	Gui,Add,Text,%sect% x%x% y%y% w%w% h%h% %style% +Center,%mode%
}
guiP(){
	Global
	Gui,Font,% "c" c.red
	%gP%()
	Gui,Font,% "c" c.blue
}
guiE(){
	Global
	Gui,Font,% "c" c.red
	%gE%()
	Gui,Font,% "c" c.blue
}
guiSection(x:="+0",y:="+0",w:=0,h:=0){
	Gui,Add,Text,Section x%x% y%y% w%w% h%h%
}
incChars(chars,inc:=2){
	Loop,%inc%
		ret.=chars
	Return ret
}
WM_LBUTTONDOWN(argV*){
	Global		A_TempLBH:=A_TickCount
			,	A_LBD_X:=HiLoBytes(argV[2]).Low
			,	A_LBD_Y:=HiLoBytes(argV[2]).High
			,	A_GuiId
	If MouseOver(272,4,296,28,"Client")
		Gui,Destroy
	If MouseOver(0,0,A_GuiWidth,32,"Client")
		PostMessage, 0xA1, 2,,,% "ahk_id " A_GuiId
	Mem.emptyMem()
}
WM_LBUTTONUP(argV*){
	Global		A_TempLBH, A_LBD_X, A_LBD_Y
			,	A_LButtonHeld:=Round((A_TickCount-A_TempLBH)/1000,3)
			,	A_LBU_X:=HiLoBytes(argV[2]).Low
			,	A_LBU_Y:=HiLoBytes(argV[2]).High
			, 	A_GuiId
	a:=(A_LBD_X>=A_LBU_X)?A_LBU_X:A_LBD_X
	b:=(A_LBD_Y>=A_LBU_Y)?A_LBU_Y:A_LBD_Y
	c:=(A_LBD_X>=A_LBU_X)?A_LBD_X:A_LBU_X
	d:=(A_LBD_Y>=A_LBU_Y)?A_LBD_Y:A_LBU_Y
	ToolTip
	Mem.emptyMem()
}
HiLoBytes(bytes,array:=0){
	Return	!	array
			?	{"High":(bytes>>16) & 0xffff,"Low":bytes & 0xffff}
			:	[(bytes>>16) & 0xffff,bytes & 0xffff]
}
GuiButton(title,txtvar,prgssvar,buttonHwnd,bTxtHwnd,subWin:="",color:="0x1D1D1D",border:="0x1D1D1D",x:="+0",y:="+0",w:="",h="",center:="Center"){ 
	Global
	%txtvar%:=title
	%prgssvar%:=100
	Gui,%subWin%Add,Progress,v%prgssvar% x%x% y%y% w%w% h%h% Background%border% c%color% Hwnd%buttonHwnd%,100
	Gui,%subWin%Add,Text,w%w% h%h% xp yp %center% +BackgroundTrans 0x200 v%txtvar% Hwnd%bTxtHwnd%,%title%
}
RunAsAdmin(file,argV*){
	If FileExist(file) {
		If IsObject(argV) {
			For idx, param in argV
				params.=A_Space param
			If	!A_IsAdmin	{
				Try, Run *RunAs %file% %params%
				Catch
					Return 0
			}	Else	{
				Try, Run %file% %params%
				Catch
					Return 0			
			}
			If (file=A_ScriptFullPath Or file=A_ScriptName)
				ExitApp
			Return 1
		}
	}
}
guiEquals(x,y,w,h){
	Gui,Add,Text,x%x% y%y% w8 h24 +Center,=
}
guiPlus(x,y,w,h){
	Gui,Add,Text,x%x% y%y% w8 h24 +Center,+
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Classes                                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Class Sound {
	get(args*){
		SoundGet,lvl,% args[1],% args[2],% args[3]
		Return args[2]?(lvl="On"):Round(lvl,0)
	}
	set(args*){
		SoundSet,% args[1],% args[2],% args[3],% args[4]
		Return ! ErrorLevel
	}
	adjust(inc:=1,tip:=0,sub:="EndToolTip",endTime:=3000){
		this.set((this.get()+inc))
		ToolTip % tip?"Volume: " this.get() "%":""
		If tip
			SetTimer,%sub%,-%endTime%
	}
}
Class Mem {
	emptyMem(pid=""){
		pid:=!pid?DllCall("GetCurrentProcessId"):pid
		hVar:=DllCall("OpenProcess","UInt",0x001F0FFF,"Int",0,"Int",pid)
		DllCall("SetProcessWorkingSetSize", "UInt", hVar, "Int", -1, "Int", -1)
		DllCall("CloseHandle","Int",hVar)
	}
	freeRam(pid:=""){
		If ! pid
			for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
				this.emptyMem(process.processID)
		Else	this.emptyMem(pid)
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subs                                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s1:
	s.adjust(,tTime,,tTime)
	Mem.emptyMem()
Return
s2:
	s.adjust(-1,tTime,,tTime)
	Mem.emptyMem()
Return
s3:
	s.adjust(10,tTime,,tTime)
	Mem.emptyMem()
Return
s4:
	s.adjust(-10,tTime,,tTime)
	Mem.emptyMem()
Return
s5:
	If s.set(-1,,"Mute") {
		If tTime {
			ToolTip,% s.get(,"Mute")?"Mute is On":"Mute is Off"
			SetTimer,EndToolTip,% tTime
		}
	}
	initMenu()
	Mem.emptyMem()
Return
Help:
	helpWindow()
	Mem.emptyMem()
Return
EndToolTip:
	ToolTip
Return
GuiClose:
GuiEscape:
	Gui,Destroy
	hTxtV:=hPrgrssV:=hButtonHwnd:=hBTxtHwnd:=""
	Mem.emptyMem()
Return
Exit:
	ExitApp