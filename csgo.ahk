#include <classMemory>
#include <gdi>


;##########################################################################
#define inimigo := 0x000000FF
inimigoBrush = Gdip_BrushCreateSolid(inimigo)

;tamanhos da tela
WinGetPos,,, tela_largura, tela_altura, Counter-Strike: Global Offensive - Direct3D 9

;Offsets
Global FL_ONGROUND    := 1<<0
dwLocalPlayer := 0xDB558C
m_iCrosshairId := 0x11838
dwEntityList  := 0x4DD0A84
m_iHealth := 0x100
m_iTeamNum = 0xF4
dwForceJump = 0x527A97C


;##########################################################################
IF NOT A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

#SingleInstance Force
SendMode, Input

;##########################################################################

DecToHex(Value)
{
	SetFormat IntegerFast, Hex
	Value += 0
	Value .= "" ;required due to 'fast' mode
	SetFormat IntegerFast, D
	Return Value
}

;########################################################################## Checar a classe da memoria

if (_ClassMemory.__Class != "_ClassMemory")
{
    msgbox class memory not correctly installed. 
    ExitApp
}

mem := new _ClassMemory("ahk_exe csgo.exe",, hProcessCopy)

if !isObject(mem) 
{
    if (hProcessCopy = 0)
        msgbox The program isn't running (not found) or you passed an incorrect program identifier parameter. 
    else if (hProcessCopy = "")
        msgbox OpenProcess failed. If the target process has admin rights, then the script also needs to be ran as admin. _ClassMemory.setSeDebugPrivilege() may also be required. Consult A_LastError for more information.
    ExitApp
}

moduleBase := mem.getModuleBaseAddress("client.dll")

;########################################################################## Vars facilitadoras

janela := "Counter-Strike: Global Offensive - Direct3D 9"
identificador := "ahk_exe csgo.exe"
exe := "csgo.exe"


playerBase := mem.read(moduleBase + dwLocalPlayer, "UInt")
localPlayerTeam := mem.read(playerBase + m_iTeamNum, "UInt")
xhairEntity := mem.read(playerBase + m_iCrosshairId, "UInt")
EntityBase := mem.read(moduleBase + dwEntityList + (xhairEntity - 1) * 0x10, "UInt")
EntityTeam := mem.read(EntityBase + m_iTeamNum, "UInt")
EntityHealth := mem.read(EntityBase + m_iHealth, "UInt")


class _EnemyPlayer
{
	Name := "" ; string
	Positon := "" ; Vector
	PoseType := ""
	Velocity := "" ; Vector
	Health := "" ; float
	HealthMax := "" ; float
	TeamID := ""
	Occluded := ""
	VehiclePosition := "" ; Vector
	VehicleTransform := "" ;Matrix
	VehicleVelocity := "" ; Vector
	VehicleHealth := "" ;float
	VehicleHealthMax := "" ; float
	SoldierPointer := "" ; Int64
	Rect := {}
	DistanceCH := ""
	
	IsVisible()
	{
		if (this.Occluded = 1)
			return false
		else
			return true
	}
	
	
	AABB()
	{
		aabb := {}
		if (this.PoseType = 0)
		{
			aabb[1] := [-0.35,0.0,-0.35], aabb[2] := [ 0.35,1.7, 0.35]
		}
		if (this.PoseType = 1)
		{
			aabb[1] := [-0.35,0.0,-0.35], aabb[2] := [ 0.35,1.15, 0.35]
		}
		if (this.PoseType = 2)
		{
			aabb[1] := [-0.35,0.0,-1.2], aabb[2] := [ 0.35,0.4, 0.6]
		}
		return aabb
	}
	
}


pressed:= false

SetTimer, trigger, 180
trigger:

;esp


;triggerbot
while (GetKeyState("LAlt", "P")) {
   playerBase := mem.read(moduleBase + dwLocalPlayer, "UInt")
   localPlayerTeam := mem.read(playerBase + m_iTeamNum, "UInt")
   xhairEntity := mem.read(playerBase + m_iCrosshairId, "UInt")
   EntityBase := mem.read(moduleBase + dwEntityList + (xhairEntity - 1) * 0x10, "UInt")
   EntityHealth := mem.read(EntityBase + m_iHealth, "UInt")
   EntityTeam := mem.read(EntityBase + m_iTeamNum, "UInt")
   
   valor1:= DecToHex(playerBase)
   valor2:= DecToHex(localPlayerTeam)
   valor3:= DecToHex(xhairEntity)
   valor4:= DecToHex(EntityBase)
   valor5:= DecToHex(EntityTeam)
   valor6:= DecToHex(EntityHealth)
   

   if (xhairEntity > 0) {
	  if (EntityTeam != localPlayerTeam && EntityHealth > 0) {
		 Sleep, 50
         Click, left;
         Sleep, 250
	  }
   }
}

;bhop
pressed1 := true
while (GetKeyState("Space")) {
inAir:= mem.read(playerBase+0x104, "UInt")
;MsgBox, %inAir%
if (inAir & FL_ONGROUND) {
   mem.write(moduleBase+0x527A97C, 6, "Int")
}
}
NumpadDiv::pressed1 := true
NumpadMult::pressed := true