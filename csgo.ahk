#NoEnv
;#include <classMemory>
;#include <gdi>
#Include <GDIMLIB>
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
#KeyHistory 0
; Process, Priority, , N
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1
SetMouseDelay, -1
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
;Critical, On ; On or 7 or 10
Thread, Interrupt, 0
;SetFormat, IntegerFast, hex
g := ""
mem := 0
Freezeproc := 0
pressed := 0
ESP := 1
CShWnd := 0

;Offsets e definiçoes
Global FL_ONGROUND    := 1<<0
vermelho := new GDI.Pen(0x0000FF)

m_vecOrigin = 0x138
dwViewMatrix = 0x4DC1394
dwLocalPlayer := 0xDB458C ;0xDB558C
m_iCrosshairId := 0x11838 ;0x11838
dwEntityList  := 0x4DCFA94 ;0x4DD0A84
m_iHealth := 0x100
m_iTeamNum := 0xF4
dwForceAttack := 0x31FFFA4
dwForceJump := 0x527998C ;0x527A97C
vm:=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
posicao:=[0,0,0]
head:=[0,0,0]
screenpos:=[0,0,0]
screenhead:=[0,0,0]


IfWinExist,Counter-Strike: Global Offensive - Direct3D 9
{
		mem := new _ClassMemory("ahk_exe csgo.exe","PROCESS_ALL_ACCESS")

			CShWnd := WinExist("Counter-Strike: Global Offensive - Direct3D 9")
			WinGet,CSpid,PID,Counter-Strike: Global Offensive - Direct3D 9
			gosub, CreateOverlay
			SetTimer, ReadData, 1
}

return

CreateOverlay:
WinGetPos, WindowX,WindowY,WindowW,WindowH,Counter-Strike: Global Offensive - Direct3D 9
Gui, 2: +LastFound +AlwaysOnTop ;+E0x20 +E0x80000 -Caption +LastFound +OwnDialogs +Owner  ;+E0x80000 all screens
Gui, 2: color , 0x000000
Gui, 2: Show, x%WindowX% y%WindowY% w%WindowW% h%WindowH%, Overlay
WinSet, Style, -0xC00000, Overlay ; remove title bar name
WinSet, Style, +0x0, Overlay ; overlap window
WinSet, Style, -0xC40000, Overlay ; set boarderless windowed mode
WinSet, ExStyle, +0x20, Overlay ; transparant
WinSet, ExStyle, +0x80, Overlay ; remove alt tab
WinSet, ExStyle, +0x80000, Overlay ; overlap
WinSet, TransColor, 0x000000, Overlay ; make everything black -> trans
hOverlay := WinExist("Overlay")
return

DrawInfoUpdate:
g := new GDI(hOverlay,WindowW,WindowH,0x000000) ;g.NewScene()
g.BitBlt()
return

ReadData:
	; START OUR PLAYER
	if (ESP)
	{
		g := new GDI(hOverlay,WindowW,WindowH,0x000000) ;g.NewScene()
	}

	moduleBase := mem.getModuleBaseAddress("client.dll")
	playerBase := mem.read(moduleBase + dwLocalPlayer, "UInt")
	localPlayerTeam := mem.read(playerBase + m_iTeamNum, "UInt")
	xhairEntity := mem.read(playerBase + m_iCrosshairId, "UInt")
	EntityBase := mem.read(moduleBase + dwEntityList + (xhairEntity - 1) * 0x10, "UInt")
	EntityTeam := mem.read(EntityBase + m_iTeamNum, "UInt")
	EntityHealth := mem.read(EntityBase + m_iHealth, "UInt")
	vm := mem.read(moduleBase + dwViewMatrix, "Float", "Matrix")
	localteam1 = mem.read(moduleBase + dwEntityList, "UInt")
	localteam = mem.read(localteam1 + m_iTeamNum, "UInt"))
	
total := 1
    while(total < 64) {
      players := mem.read(moduleBase + dwEntityList + total * 0x10, "UInt")
      health := mem.read(players + m_iHealth, "UInt")
      team := mem.read(players + m_iTeamNum, "UInt")
      posicao := mem.read(players + m_vecOrigin, "Float", "Vector")

      head[1] := posicao[1]
      head[2] := posicao[2]
      head[3] := posicao[3] + 75
      screenpos := WorldToScreen(posicao, vm)
      screenhead := WorldToScreen(head, vm)
      
      height := screenhead[2] - screenpos[2]
      width := height / 2.4
      if (screenpos[2] >= 0.01 && team != localPlayerTeam && health > 0 && health < 101)
      {
		;g.DrawRectangle(screenpos[1]-(width/2), screenpos[2], width, 1, vermelho) ;pé
	    ;g.DrawRectangle(screenpos[1]-(width/2), screenpos[2]+height, width+1, 1,1) ; cabeça
	    ;g.DrawRectangle(screenpos[1]-(width/2), screenpos[2], 1, height, vermelho) ; barra lateral direita
        ;g.DrawRectangle(screenpos[1]-(width/2)+width, screenpos[2], 1, height, vermelho) ; barra lateral esquerda
		;g.DrawRectangle(screenpos[1]-(width/2)+width/2, screenpos[2], 1, height, vermelho) ; barra lateral esquerda
		g.DrawText(screenpos[1]-(width/2), screenpos[2], width, 1, Inimigo, vermelho, Typeface, 3, "LT", 500, 0)
      }
    total++
    }
;trigger:

if (GetKeyState("LAlt", "P")) {
   playerBase := mem.read(moduleBase + dwLocalPlayer, "UInt")
   localPlayerTeam := mem.read(playerBase + m_iTeamNum, "UInt")
   xhairEntity := mem.read(playerBase + m_iCrosshairId, "UInt")
   EntityBase := mem.read(moduleBase + dwEntityList + (xhairEntity - 1) * 0x10, "UInt")
   EntityHealth := mem.read(EntityBase + m_iHealth, "UInt")
   EntityTeam := mem.read(EntityBase + m_iTeamNum, "UInt")
   
  
   if (xhairEntity > 0) {
	  if (EntityTeam != localPlayerTeam && EntityHealth > 0) {
		 Sleep, 50
         mem.write(moduleBase+dwForceAttack, 6, "Int")
         Sleep, 250
	  }
   }
}

;bhop:
if (GetKeyState("Space", "P")) {
inAir:= mem.read(playerBase+0x104, "UInt")
;MsgBox, %inAir%
if (inAir & FL_ONGROUND) {
   mem.write(moduleBase+dwForceJump, 6, "Int")
}
}
	if (ESP)
	{
		g.BitBlt(WindowX,WindowY,WindowW,WindowH)
	}
	IfWinNotActive,Counter-Strike: Global Offensive - Direct3D 9
	{
		ESP := 0
		g := new GDI(hOverlay,WindowW,WindowH,0x000000) ;g.NewScene()
		g.BitBlt(WindowX,WindowY,WindowW,WindowH)
	}
	else
	{
		ESP := 1
	}
	
return


WorldToScreen(poss, matrix)
{
    x1 := matrix[1][1] * poss[1] + matrix[1][2] * poss[2] + matrix[1][3] * poss[3] + matrix[1][4]
    y1 := matrix[2][1] * poss[1] + matrix[2][2] * poss[2] + matrix[2][3] * poss[3] + matrix[2][4]
    
    w := matrix[4][1] * poss[1] + matrix[4][2] * poss[2] + matrix[4][3] * poss[3] + matrix[4][4]
    inv_w := 1/w
    x1 *= inv_w
    y1 *= inv_w
    x := A_ScreenWidth * 0.5
    y := A_ScreenHeight * 0.5
    
    x += 0.5 * x1 * A_ScreenWidth + 0.5
    y -= 0.5 * y1 * A_ScreenHeight + 0.5
    
    return [x,y,w]
}
