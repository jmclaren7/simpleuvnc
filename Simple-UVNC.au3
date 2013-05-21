#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=icon.ico
#AutoIt3Wrapper_outfile=Simple-UVNC.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Description=Simple-UVNC
#AutoIt3Wrapper_Res_Fileversion=4.0.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=n
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Run_Obfuscator=n
#Obfuscator_Parameters=/StripOnly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;>COMPILE NOTES:
;>Autoit Version: 3.3.0.0  http://www.autoitscript.com
;>Be sure you have installed the script editor from http://www.autoitscript.com as well, otherwise some compile options will be ignored.
;>I use a 3rd party UPX/exe compressor, so if you compile at home, adjust the above "#AutoIt3Wrapper_UseUpx" setting to "y"
;>If you want to use your own icon, place the .ico file in the script folder and change "#AutoIt3Wrapper_icon=" to = the filename of your icon.
;>This version needs the beta obfuscator 1.0.26.15 or later: http://www.autoitscript.com/autoit3/scite/download/beta_SciTE4AutoIt3/
;	OR set "#AutoIt3Wrapper_Run_Obfuscator=" to "n"
;

;===Autoit Scripting Options===========================================
Opt("TrayMenuMode", 1)
Opt("TrayOnEventMode", 1)
Opt("GUIResizeMode",802)
Opt("MouseCoordMode", 1)
Opt("WinWaitDelay", 50)

;===Check To Hide Console Window========================================
if @UserName <> "John McLaren" then WinSetState("[REGEXPTITLE:"&@ScriptName&"; CLASS:ConsoleWindowClass]","",@SW_MINIMIZE)

;===Pre-Run Checks======================================================
_only_instance(3);3=Prompt to run anyway
_ConsoleWrite(EnvGet("SESSIONNAME"))
if EnvGet("sessionname")="RDP*" then msgbox(48,"UVNC-Helper","Please note that running this program from within a RDP session will likely fail.",30)
if @compiled=9 then;Used Only for test purposes when script is executed as uncompiled
	msgbox(0,"Testing...","Currently Nothing To Do Uncompiled")
	Exit
EndIf

;===Program Specific Globals============================================
Global $sServiceName="uvnc_service_autoit"
Global $APPDIR=@TempDir&"\uvnc_autoit"
Global $APPVER="1.0.6.3"
Global $APPEXE="winvnc_autoit.exe"
Global $APPINI="ultravnc.ini"
Global $APPEXEFULL=$APPDIR&"\"&$APPEXE
Global $APPINIFULL=$APPDIR&"\"&$APPINI

Global $SLEEP_PING=20000
Global $SLEEP_PINGREAD=8000
Global $SLEEP_TIMER=1000

;===Get File Version And Trim It========================================
Global $VERSION_O=FileGetVersion(@AutoItExe)
Global $VERSION=StringLeft($VERSION_O, StringLen($VERSION_O) - StringInStr($VERSION_O,".0.0",0,1,StringInStr($VERSION_O,".",0,2)))
_ConsoleWrite("Version "&$VERSION_O&" / "&$VERSION)

#Obfuscator_off
;===Misc Globals======================================================== Do Not Edit Any Of These Values, They Need To Be Set In Other Places Or Not At All
Global $DEBUGLOG ;Use Embed Option.. unless we need to activate debug logging within 750ms of program execution
Global $TITLE ;DONT SET BECAUSE WE WILL ADD $OPTION_TITLE & $VERSION TOGETHER LATER
Global $TITLE_ADVANCED
Global $LAST_ADLIB_CONNECTION=0
Global $MW_INPUT1, $MW_INPUT2
Global $MULTIHOST_CONVERT
Global $OPTION_HOST_DISPLAY
Global $EMBED_DATA_START
Global $EMBED_DATA_END
Global $LAST_DEBUG_OPTION=1
Global $GUI_STYLE_HOST
Global $GUI_STYLE_PORT
Global $STAT_EMBED_PASS

;===Global Statuses========================================================
Global $STAT_STOPPEDUVNCSERVICE=0 ;Changes when an existing running instance of uvnc_service is found so that it will be restarted on exit
Global $STAT_STARTEDACONNECTION=0 ;Changes when any connection attempt is made for the purpose of preventing an unneeded -kill
Global $STAT_VNCISCONNECTED=0 ;Uses AdLib to monitor connection status (under development)
Global $STAT_FOUNDEMBEDDATA=0 ;Chnages if the program finds embed data appended to the executable, used for the embed command to know to remove the old data
Global $STAT_DOCKHIDDEN=0 ;Changes when dock is moved into view and when its moved out of view
Global $STAT_EXITING=0 ;Changes when exit procedure starts, to prevent calls to the GUI from the Adlib func because autoit deletes the GUI early on in the OnExitFunc, but keeps the Adlib func alive
;Global $STAT_DISABLEDSECUREDESKTOP=0 ;Changes if run in service mode 31 and secure desktop is disabled

;===Default Embed Values====================================================
Global	$OPTION_1_SHORT="HOST"
Global 	$OPTION_HOST=""
Global 	$OPTION_HOST_DESC="The default host address. Use [friendlyname] in front of the address to use a friendly name. use a ; between addresses to specify more then one host, Use a friendly name with no value to make the option non selectable. Default is blank"&@CRLF&@CRLF&"example: ""[Select Tech]; [John]support.teammc.cc:5511; [Allyssa]support2.teammc.cc"""
Global	$OPTION_2_SHORT="PORT"
Global 	$OPTION_PORT="5500"
Global 	$OPTION_PORT_DESC="The port number to be displayed in the port input by default. Default is 5500"
Global	$OPTION_3_SHORT="TITLE"
Global 	$OPTION_TITLE="TeamMC UVNC-Helper"
Global 	$OPTION_TITLE_DESC="The title to be displayed in the window title bar. Default is TeamMC UVNC-Helper"
Global	$OPTION_4_SHORT="SERVICE"
Global	$OPTION_SERVICE="1"
Global	$OPTION_SERVICE_DESC="Desides if UVNC will run as a service or as the user. Default is 1"&@CRLF&"1=Runs as service if vista AND admin."&@CRLF&"3=Runs as service if user is admin."&@CRLF&"4=Runs as service."&@CRLF&"5=Runs as user."
Global	$OPTION_5_SHORT="REPO"
Global 	$OPTION_REPO="http://repo.teammc.cc"
Global 	$OPTION_REPO_DESC="URL to the AptGet repository, for using command aptget / ag. Url must not have a trailing backslash. Default is http://repo.teammc.cc"
Global 	$OPTION_6_SHORT="GETDESC"
Global 	$OPTION_GETDESC="1"
Global 	$OPTION_GETDESC_DESC="Disables/Enables attempting to get descriptions when using AptGet Lister. Default is 1"
Global	$OPTION_7_SHORT="WINDOW"
Global 	$OPTION_WINDOW="1"
Global 	$OPTION_WINDOW_DESC="Changes the behavior of the programs windows. 1"&@CRLF&"1=Always on top, Tool window, No task bar."&@CRLF&"2=Normal window."&@CRLF&"3=UVNC/RDP style docking."
Global	$OPTION_8_SHORT="PROMPT"
Global 	$OPTION_PROMPT="1"
Global 	$OPTION_PROMPT_DESC="Prompts viewer to accept connection just like the old SC. Only works when running as user. Default is 1"
Global	$OPTION_9_SHORT="RECONNECT"
Global	$OPTION_RECONNECT="1"
Global	$OPTION_RECONNECT_DESC="If the viewer disconnects the server will automaticly try to reconnect to it. Default is 1"&@CRLF&"0=Use sc_autoexit. (User mode only)"&@CRLF&"1=Reconnect Automaticly (User or service)."&@CRLF&"3=Nothing"
Global	$OPTION_10_SHORT="DEBUG"
Global	$OPTION_DEBUG="1"
Global	$OPTION_DEBUG_DESC="Enables/Disables a debug log, the log will be output to the current directory as ""programname_LOG.txt"". Default is 0"
Global	$OPTION_11_SHORT="R1";Reserved For Testing/Dev
Global 	$OPTION_R1="";Reserved For Testing/Dev
Global	$OPTION_12_SHORT="R2";Reserved For Testing/Dev
Global	$OPTION_R2="";Reserved For Testing/Dev
Global	$OPTION_13_SHORT="DSM"
Global 	$OPTION_DSM="0"
Global 	$OPTION_DSM_DESC="Uses a DSM plugin to encrypt your connection. Default is 0"&@CRLF&"0=Disable"&@CRLF&"1=MSRC4Plugin_NoReg.dsm"
Global	$OPTION_14_SHORT="PASS"
Global 	$OPTION_PASS=""
Global 	$OPTION_PASS_DESC="Pre encrypted password from your uvnc.ini file."
Global	$OPTION_15_SHORT="LOCK"
Global	$OPTION_LOCK="0"
Global	$OPTION_LOCK_DESC="Prevents the host and/or port field from being edited. Default is 0"&@CRLF&"0=Disable"&@CRLF&"1=Lock both."&@CRLF&"2=Lock host only"&@CRLF&"3=Lock port only"
Global	$OPTION_16_SHORT="SITE"
Global 	$OPTION_SITE=""
Global 	$OPTION_SITE_DESC="URL to the support providers website, if specified a tray icon item will be available. Default is blank"
Global	$OPTION_17_SHORT="EMBED"
Global 	$OPTION_EMBED="1"
Global 	$OPTION_EMBED_DESC="Prevents the use of the 'embed' command."&@CRLF&"0=Disable"&@CRLF&"1=Allow"&@CRLF&"Non 0/1=Set as password to access later."

Global $OPTION_IMAGE=""
Global $OPTION_RC4=""


$i=1
while IsDeclared("OPTION_"&$i&"_SHORT")
	Assign("OPTION_DEFAULT_"&$i,Eval("OPTION_"&Eval("OPTION_"&$i&"_SHORT")),2)
	$i=$i+1
wend
#Obfuscator_On
;===Files To Include=======================================================
#include <Inet.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#Include <String.au3>

#include "CommonFunctions.au3"
#include "ServiceControl.au3"

;===Adlib Functions========================================================
AdlibRegister( "adlib_master",750)

;===Tray Icon Options======================================================
TrayCreateItem("Exit")
TrayItemSetOnEvent (-1,"tray_exit")
TrayCreateItem("Open Temp Folder")
TrayItemSetOnEvent (-1,"tray_open_temp_folder")
TrayCreateItem("Open Current Folder")
TrayItemSetOnEvent (-1,"tray_open_current_folder")
TrayCreateItem("About UVNC-Helper")
TrayItemSetOnEvent (-1,"tray_about")

;====Proccess Embed Data===================================================
if @Compiled then
	$file_hand=FileOpen(@ScriptFullPath,16)
	$file_data=FileRead($file_hand)
	FileClose($file_hand)

	$file_data=BinaryToString($file_data)
	$EMBED_DATA_START=StringInStr($file_data,"<TEAMMCDATA=STARTDATA>",1)
	$EMBED_DATA_END=StringInStr($file_data,"<TEAMMCDATA=ENDDATA>",1,1,$EMBED_DATA_START)
	if $EMBED_DATA_START<>0 AND $EMBED_DATA_END<>0 then
		$EMBED_DATA_START=$EMBED_DATA_START+StringLen("<TEAMMCDATA=STARTDATA>")
		$embed_data_count=$EMBED_DATA_END-$EMBED_DATA_START
		$file_data=stringmid($file_data,$EMBED_DATA_START,$embed_data_count)
		;_ConsoleWrite($file_data)
		$file_data=StringSplit($file_data,"<TEAMMCDATA=",1+2)

		if ubound($file_data)>1 then
			for $i=1 to ubound($file_data)-1

				$var=stringleft($file_data[$i],StringInStr($file_data[$i],">")-1)
				$data=stringmid($file_data[$i],StringInStr($file_data[$i],">")+1)
				if $data <> "" then
					_ConsoleWrite("Embed: "&$var&" = "&$data)
					if Assign ("OPTION_"&$var,$data,4)=0 then _ConsoleWrite(" (Failed To Set)",1)
				else
					_ConsoleWrite("Embed: Found Empty Command: "&$var)
				endif
			Next

			$STAT_FOUNDEMBEDDATA=1
		Else
			_ConsoleWrite("No Embed Data (Found Start Tag)")
		endif
	Else
		_ConsoleWrite("No Embed Data")
	EndIf
Else
	_ConsoleWrite("No Embed Data (Not Compiled)")
endif

;===Proccess some information based on what we found embeded===============================
_ConsoleWrite("Using Embed Data For Special Settings")
adlib_gui()

if $OPTION_EMBED=0 then
	$STAT_EMBED_PASS=-1
elseif $OPTION_EMBED=1 then
	$STAT_EMBED_PASS=1
else
	$STAT_EMBED_PASS=$OPTION_EMBED
	$OPTION_EMBED=0
EndIf

$GUI_STYLE_HOST=$GUI_SS_DEFAULT_COMBO
$GUI_STYLE_PORT=-1
Switch $OPTION_LOCK
		case 1
			$GUI_STYLE_HOST=$CBS_DROPDOWNLIST
			$GUI_STYLE_PORT=$ES_READONLY
		case 2
			$GUI_STYLE_HOST=$CBS_DROPDOWNLIST
		case 3
			$GUI_STYLE_PORT=$ES_READONLY
EndSwitch

If $OPTION_SITE<>"" Then
	TrayCreateItem($OPTION_TITLE)
	TrayItemSetOnEvent (-1,"tray_site")
endif

Switch $OPTION_WINDOW
	Case 1, 3
		$MW_EXSTYLE=BitOR($WS_EX_APPWINDOW,$WS_EX_TOOLWINDOW,$WS_EX_TOPMOST,$WS_EX_STATICEDGE)
		$MW_STYLE=-1

	Case 2
		$MW_EXSTYLE=$WS_EX_APPWINDOW
		$MW_STYLE=-1

EndSwitch

;===Multiple Hosts Proccessing=====================================================================
_ConsoleWrite("Multiple Hosts Proccessing")
Global $MULTIHOST=StringSplit($OPTION_HOST,";")
Global $MULTIHOST_CONVERT[$MULTIHOST[0]+1][2]
Local $HostDisplay
for $i=1 to $MULTIHOST[0]
	$HostDisplay=$MULTIHOST[$i]
	if StringInStr($MULTIHOST[$i],"[") AND StringInStr($MULTIHOST[$i],"]") then;See if an alias is specified
		$MULTIHOST_CONVERT[$i][0]=StringMid($MULTIHOST[$i],StringInStr($MULTIHOST[$i],"[")+1,StringInStr($MULTIHOST[$i],"]")-1-StringInStr($MULTIHOST[$i],"["));The Display Name
		$HostDisplay=$MULTIHOST_CONVERT[$i][0]
		$MULTIHOST_CONVERT[$i][1]=StringReplace($MULTIHOST[$i],"["&$MULTIHOST_CONVERT[$i][0]&"]","");The Host Address
	endif
	$OPTION_HOST_DISPLAY=$OPTION_HOST_DISPLAY&$HostDisplay&"|"
next

;===Create GUI=====================================================================================
_ConsoleWrite("Create Main GUI")
;Global $MainWindow = GUICreate($TITLE, 186, 45,100,100,$MW_STYLE,$MW_EXSTYLE)
Global $MainWindow = GUICreate($TITLE,379,290,-1,-1,-1,$WS_EX_TOPMOST)
GUISetFont (11)

_ConsoleWrite("Create GUI - Select Connection")
GUICtrlCreateGroup("Select A Connection",5,5,369,80)
GUICtrlCreateLabel(":",195,42,4,24)
Global $MW_INPUT2 = GUICtrlCreateInput($OPTION_PORT,201,40,54,24,$GUI_STYLE_PORT)
Global $MW_BUTTON1 = GUICtrlCreateButton("Connect",258,39,75,24,$BS_DEFPUSHBUTTON)

;GUICtrlCreateLabel("Please select a remote support connection and press connect.", 85, 102, 200, 24)

_ConsoleWrite("Create GUI - Command Box")
Global $MW_INPUT3 = GUICtrlCreateInput("",80,230,137,24)
Global $MW_BUTTON2 = GUICtrlCreateButton("Command",220,229,75,24)
;Global $MW_BUTTON3 = GUICtrlCreateButton("X",237, 0, 21, 21)

_ConsoleWrite("Create GUI - Combo")
Global $MW_INPUT1 = GUICtrlCreateCombo("", 40,40, 153, 24,$GUI_STYLE_HOST);NEEDS TO BE MADE IN THIS ORDER BECAUSE OF WINDOWS GUI HANDLES/CONTROL NAMING
GUICtrlSetData(-1,$OPTION_HOST_DISPLAY)
GUICtrlSetData(-1,StringLeft($OPTION_HOST_DISPLAY,StringInStr($OPTION_HOST_DISPLAY,"|")-1))

Global $MW_DUMMY=GUICtrlCreateDummy()

_ConsoleWrite("Create GUI - Tips")
GUICtrlSetTip ($MW_INPUT1,"Type The IP Address Or Domain Of The Computer You Want To Connect To")
GUICtrlSetTip ($MW_INPUT2,"Type The Port To Connect On, Deault Is 5500")
GUICtrlSetTip ($MW_BUTTON1,"Press This To Start Or Stop The Connection")
GUICtrlSetTip ($MW_INPUT3,"Special Commands Go Here")
GUICtrlSetTip ($MW_BUTTON2,"Press This To Execute A Special Command")



;==Show Window And Get Handle For Internal Window Modification==================================
_ConsoleWrite("Window Show")
GUISetState(@SW_SHOW)
GUICtrlSetState ($MW_INPUT1,$GUI_FOCUS)
$TITLE_ADVANCED=WinGetHandle("[CLASS:AutoIt v3 GUI; TITLE:"&$TITLE&"]")

;==Command Line System==========================================================================
_ConsoleWrite("Command Line Proccessing")
If $CmdLine[0]=0 Then
	_ConsoleWrite("No Command Line")

Else
	for $i=1 To $CmdLine[0];Examines command line
		$Command=StringTrimLeft($CmdLine[$i],1)
		_ConsoleWrite("Command: """&$Command&"""")

		if StringLeft($CmdLine[$i],1)="-" And $CmdLine[0]>$i And StringLeft($CmdLine[$i+1],1)<>"-" Then ;HAS VALUE
			$Data=$CmdLine[$i+1]
			_ConsoleWrite("Value: """&$Data&"""")

			Switch $Command
				Case "connect"
					$Data=StringSplit($Data,":")
					If NOT @error Then GUICtrlSetData ($MW_INPUT2,$Data[2])
					GUICtrlSetData ($MW_INPUT1,$Data[1])
					GUICtrlSetData ($MW_INPUT1,$Data[1])
					GUICtrlSendToDummy ($MW_DUMMY)

				case "rconnect"
					exit

					file_install()
					service_start()
					$RUNLINE="""" & $APPEXEFULL & """ -connect "&$Data;&" -run"
					_ConsoleWrite($RUNLINE)
					Run($RUNLINE,$APPDIR,@SW_HIDE)



				Case Else
					_ConsoleWrite("Unknown Command Line Arguement: "&$CmdLine[$i]&" With Value: "&$CmdLine[$i+1])

			EndSwitch
			$i=$i+1

		ElseIf StringLeft($CmdLine[$i],1)="-" Then ;The Parameter DOESNT HAVE A VALUE
			$Command=StringTrimLeft($CmdLine[$i],1)

			Switch $Command
				Case "connect"
					GUICtrlSendToDummy ($MW_DUMMY)

				Case Else
					_ConsoleWrite("Unknown Command Line Arguement: "&$CmdLine[$i])

			EndSwitch
		Else
			_ConsoleWrite("Invalid Command Line: "&$CmdLineRaw)

		endif
	Next
EndIf



;===Main Window GUI Loop====================================================
_ConsoleWrite("Starting GUI Loop")
Local $MW_INPUT3_ORIGINAL, $MW_INPUT3_NEW="Disconnected", $TIMER_TOTAL, $TIMER_LAST, $TIMER_DISPLAY, $PING_LAST, $PING_DISPLAY, $PINGREAD_LAST, $TIMER_TIME_LAST, $FOCUS_LAST
While 1
	;$STAT_VNCISCONNECTED=1 ;FOR TESTING GUI
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE;, $MW_BUTTON3
			Exit

		Case $MW_BUTTON1, $MW_DUMMY
			;====Start Connection===============================================================
			If GUICtrlRead ($MW_BUTTON1)="Connect" Then
				_ConsoleWrite("Pressed Connect Button")

				$host_test=_sini($MULTIHOST_CONVERT,GUICtrlRead($MW_INPUT1))
				if (NOT @ERROR And $host_test="") or GUICtrlRead($MW_INPUT1)="" then ContinueLoop

				GUICtrlSetState($MW_BUTTON1,$GUI_DISABLE)
				GUICtrlSetData ($MW_BUTTON1,"Wait")
				GUICtrlSetState($MW_INPUT1,$GUI_DISABLE)
				GUICtrlSetState($MW_INPUT2,$GUI_DISABLE)
				Sleep(10)


				file_install()

				connection_start()

				_ConsoleWrite("GUI - Updating")
				GUICtrlSetState($MW_BUTTON1,$GUI_ENABLE)

			;====End Connection===============================================================
			ElseIf GUICtrlRead ($MW_BUTTON1)="End" Then
				_ConsoleWrite("Pressed End Button")
				GUICtrlSetState($MW_BUTTON1,$GUI_DISABLE)
				GUICtrlSetData ($MW_BUTTON1,"Wait")
				Sleep(10)

				connection_stop()

				_ConsoleWrite("GUI - Updating")
				GUICtrlSetState($MW_BUTTON1,$GUI_ENABLE)
				GUICtrlSetState($MW_INPUT1,$GUI_ENABLE)
				GUICtrlSetState($MW_INPUT2,$GUI_ENABLE)

			;====SOMEHOW THE BUTTON WAS PRESSED WHILE IT SAID WAIT
			Else
				MsgBox(0,"Error","Please Wait A Moment And Try Again")
			EndIf

		;====Cmd Button========================================================================
		Case $MW_BUTTON2
			_ConsoleWrite("Pressed Cmd Button")

			Local $line, $cmd, $data, $line_temp

			;====Seperation of command and data==========================================
			$line=GUICtrlRead($MW_INPUT3)

			;==
			$line_temp=$line
			If StringInStr($line_temp," ")=0 Then
				$cmd=$line_temp
				$data=""
			Else
				$cmd=StringStripWS (StringLeft($line_temp,StringInStr($line_temp," ")-1),1+2)
				$data=StringStripWS (StringTrimLeft($line_temp,StringInStr($line_temp," ")),1+2)
			EndIf
			;==

			GUICtrlSetData ($MW_INPUT3,"")

			;====ALL COMMANDS HERE=======================================================
			Switch $cmd
				Case "test1"
					_CreateService("","uvnc_service_autoit_reboot","uvnc_service_autoit_reboot",""""&@ComSpec&""" start cmd.exe /c """&@ScriptFullPath&""" -rconnect 192.168.0.1")
				Case "test2"
					If _DeleteService(@ComputerName,"uvnc_service_autoit_reboot")=0 Then MsgBox(0,"LocalService","Service Delete Failed: "&@error)
				case "pic"
					$hand=fileopen($APPDIR&"\mainwindow.jpg",2+8+16)
					filewrite($hand,$OPTION_IMAGE)
					FileClose($hand)

					$Form1 = GUICreate("Form1", 416, 291, 192, 154)
					$Pic1 = GUICtrlCreatePic($APPDIR&"\mainwindow.jpg", 264, 80, 100, 100)
					GUISetState(@SW_SHOW)

				Case "tray";==================================
					If $data=0 Then
						$data=1
					ElseIf $data=1 Then
						$data=0
					Else
						ContinueLoop
					EndIf

					IniWrite($APPINIFULL,"admin","DisableTrayIcon",$data)

				Case "exit";==================================
					Exit

				Case "vnc";==================================
					_ConsoleWrite("winvnc.exe "&$data)
					RunWait("""" & $APPEXEFULL & """ "&$data, "", @SW_HIDE)

				Case "reset";==================================
					_ConsoleWrite("Reset")
					$line_temp=$data
					If StringInStr($line_temp," ")=0 Then
						$cmd=$line_temp
						$data=""
					Else
						$cmd=StringStripWS (StringLeft($line_temp,StringInStr($line_temp," ")-1),1+2)
						$data=StringStripWS (StringTrimLeft($line_temp,StringInStr($line_temp," ")),1+2)
					EndIf

					If $data<3 Or Not IsNumber($data) Then $data=5
					$data=$data*1000

					connection_stop()

					_ConsoleWrite("Static Sleep")
					Sleep($data)

					connection_start()

				Case "cmd";==================================
					Run(@ComSpec & " /K " & $data, "")

				Case "end";==================================
					GUICtrlSendToDummy ($MW_DUMMY)

				Case "embed";==================================
					if ($STAT_EMBED_PASS=0) OR ($STAT_EMBED_PASS<>1 AND $STAT_EMBED_PASS<>inputbox($TITLE,"Enter Password.","","*",210,120)) then ContinueLoop

					GUISetState(@SW_HIDE,$MainWindow)
					embed()
					GUISetState(@SW_SHOW,$MainWindow)

				Case "set";==================================
					$line_temp=$data
					If StringInStr($line_temp," ")=0 Then
						$cmd=$line_temp
					Else
						$cmd=StringStripWS (StringLeft($line_temp,StringInStr($line_temp," ")-1),1+2)
						$data=StringStripWS (StringTrimLeft($line_temp,StringInStr($line_temp," ")),1+2)
					EndIf

					if Assign ( "OPTION_"&$cmd,$data,4)=0 then
						GUICtrlSetData ($MW_INPUT3,$line)
						GUICtrlSetState($MW_INPUT3,$GUI_FOCUS)
						_ConsoleWrite("Command Not Valid")
					endif

					switch $cmd
						case "window"
							gui_connection_ended()
							gui_connection_started()
					EndSwitch

				Case "set2";==================================
					$line_temp=$data
					If StringInStr($line_temp," ")=0 Then
						$cmd=$line_temp
					Else
						$cmd=StringStripWS (StringLeft($line_temp,StringInStr($line_temp," ")-1),1+2)
						$data=StringStripWS (StringTrimLeft($line_temp,StringInStr($line_temp," ")),1+2)
					EndIf

					if Assign ($cmd,$data,4)=0 then
						GUICtrlSetData ($MW_INPUT3,$line)
						GUICtrlSetState($MW_INPUT3,$GUI_FOCUS)
						_ConsoleWrite("Command Not Valid")
					endif
				Case "call";==================================
					$line_temp=$data
					If StringInStr($line_temp," ")=0 Then
						$cmd=$line_temp
					Else
						$cmd=StringStripWS (StringLeft($line_temp,StringInStr($line_temp," ")-1),1+2)
						$data=StringStripWS (StringTrimLeft($line_temp,StringInStr($line_temp," ")),1+2)
					EndIf

					$cmd=stringsplit($cmd," ")
					$cmd[0]="CallArgArray"

					#Obfuscator_Off
					Call ($data,$cmd)
					#Obfuscator_On

				Case Else;==================================
					GUICtrlSetData ($MW_INPUT3,$line)
					GUICtrlSetState($MW_INPUT3,$GUI_FOCUS)
					_ConsoleWrite("Command Not Valid")
			EndSwitch
	EndSwitch

	;====CHANGE DEFAULT BUTTON TO PRESS WHEN FOR WHEN YOU PUSH ENTER================
	$Focus_Status=ControlGetFocus($TITLE_ADVANCED)
	Switch $Focus_Status
		Case "Edit1", "Edit3", "ComboBox1"
			GUICtrlSetState($MW_BUTTON1,$GUI_DEFBUTTON)
		Case "Edit2"
			GUICtrlSetState($MW_BUTTON2,$GUI_DEFBUTTON)
	EndSwitch

	;====HOST/PORT BACKGROUND======================================================   DISABED TO BRING IN THE DROPDOWN BOX
;~ 	If GUICtrlRead($MW_INPUT1)="" And $Focus_Status<>"Edit1" And $Focus_Status<>"Button1" Then
;~ 		GUICtrlSetData ($MW_INPUT1,"Address")
;~ 		GUICtrlSetColor ($MW_INPUT1,0xAAAAAA)
;~ 	EndIf

;~ 	If GUICtrlRead($MW_INPUT2)="" And $Focus_Status<>"Edit2" And $Focus_Status<>"Button1" Then
;~ 		GUICtrlSetData ($MW_INPUT2,"Port")
;~ 		GUICtrlSetColor ($MW_INPUT2,0xAAAAAA)
;~ 	EndIf

;~ 	Switch $Focus_Status
;~ 		Case "Edit1", "Button1"
;~ 			If GUICtrlRead($MW_INPUT1)="Address" Then
;~ 				GUICtrlSetData ($MW_INPUT1,"")
;~ 				GUICtrlSetColor ($MW_INPUT1,0x000000)
;~ 			EndIf
;~ 			ContinueCase
;~ 		Case "Edit2", "Button1"
;~ 			If GUICtrlRead($MW_INPUT2)="Port" Then
;~ 				GUICtrlSetData ($MW_INPUT2,"")
;~ 				GUICtrlSetColor ($MW_INPUT2,0x000000)
;~ 			EndIf
;~ 	EndSwitch

	;====DOCKING MOUSE CHECK======================================================
	If $OPTION_WINDOW=3 And $STAT_VNCISCONNECTED=1 Then
		Local $mousex=MouseGetPos(0)
		Local $mousey=MouseGetPos(1)
		;Local $wpos=WinGetPos ($TITLE);BETTER NOT TO DO RELATIVE???

		If $mousey > 30 Or $mousex > 270 And $STAT_DOCKHIDDEN=0 Then
			_ConsoleWrite("Moving Dock Up")
			WinMove ($TITLE_ADVANCED,"",5,-42,Default,Default,5)
			$STAT_DOCKHIDDEN=1

		ElseIf $mousey < 7 And $mousex < 270 And $STAT_DOCKHIDDEN=1 Then
			_ConsoleWrite("Moving Dock Down")
			WinMove ($TITLE_ADVANCED,"",5,-20,Default,Default)
			$whnd=WinGetHandle("[active]")
			WinActivate ($TITLE_ADVANCED)
			WinActivate ($whnd)
			$STAT_DOCKHIDDEN=0

		EndIf
	EndIf

	;====TIMER AND PING AREA======================================================
	Switch $Focus_Status
		Case "Edit2", "Button2";IS IN FOCUS SO DISPLAY NOTHING OR THE PREVIOUS TXT
			If GUICtrlRead($MW_INPUT3)=$MW_INPUT3_NEW And GUICtrlRead($MW_INPUT3)<>$MW_INPUT3_ORIGINAL Then
				GUICtrlSetData ($MW_INPUT3,$MW_INPUT3_ORIGINAL)
				GUICtrlSetColor ($MW_INPUT3,0x000000)
				$MW_INPUT3_ORIGINAL=""
			EndIf


		Case Else;ISNT IN FOCUS SO DISPLAY PING AND RECORD OLD TXT
			If $MW_INPUT3_NEW<>GUICtrlRead($MW_INPUT3) Then $MW_INPUT3_ORIGINAL=GUICtrlRead($MW_INPUT3)

			$MW_INPUT3_NEW=$TIMER_DISPLAY&$PING_DISPLAY
			If $MW_INPUT3_NEW<>GUICtrlRead($MW_INPUT3) Then
				GUICtrlSetData ($MW_INPUT3,$MW_INPUT3_NEW)
				GUICtrlSetColor ($MW_INPUT3,0xAAAAAA)
			EndIf

	EndSwitch

	;====TIMER AND PING VALUES======================================================
	If $STAT_VNCISCONNECTED=1 Then
		If _ntime()-$TIMER_TIME_LAST>$SLEEP_TIMER Then
			$TIMER_NOW=_ntime("SEC")
			If $TIMER_LAST=0 Then $TIMER_LAST=$TIMER_NOW
			$TIMER_TOTAL=$TIMER_TOTAL+$TIMER_NOW-$TIMER_LAST
			$TIMER_LAST=$TIMER_NOW

			$TIMER_HOURS=Int($TIMER_TOTAL/3600)
			$TIMER_MINUTES=Int(($TIMER_TOTAL-$TIMER_HOURS*3600)/60)
			$TIMER_SECONDS=Int($TIMER_TOTAL-(($TIMER_HOURS*3600)+($TIMER_MINUTES*60)))
			$TIMER_DISPLAY="Timer: "&$TIMER_HOURS&":"&$TIMER_MINUTES&":"&$TIMER_SECONDS&"  "

			$TIMER_TIME_LAST=_ntime()
		EndIf

		If _ntime()-$PING_LAST>$SLEEP_PING Then
			Run(@AutoItExe & ' /AutoIt3ExecuteLine "IniWrite('''&$APPDIR&'\temp.ini'',''default'',''ping'',Ping('''&GUICtrlRead($MW_INPUT1)&''',''1000''))"')

			$PING_LAST=_ntime()
		EndIf

		If _ntime()-$PINGREAD_LAST>$SLEEP_PINGREAD Then
			$PING_DISPLAY="Ping: "&IniRead($APPDIR&"\temp.ini","default","ping","0")

			$PINGREAD_LAST=_ntime()
		EndIf

	Else
		$TIMER_LAST=0

	EndIf

	Sleep(10)
WEnd

;====================================================================================================================================
;====================================================================================================================================
;====================================================================================================================================
Func adlib_master()
	_ConsoleWrite(".",1)
	adlib_gui()

	;If $STAT_STARTEDACONNECTION=1 Then
	;	Local $fhand=FileOpen("WinVNC.log",0)
	;	If $fhand <> -1 Then
	;		$fline=FileRead($fhand)

	;	EndIf

	;EndIf

EndFunc
func adlib_gui()
	$TITLE=$OPTION_TITLE&" "&$VERSION; Set Final Display Title
	$DEBUGLOG=$OPTION_DEBUG

	If $LAST_ADLIB_CONNECTION<>$STAT_VNCISCONNECTED And $STAT_EXITING=0 Then
		If $STAT_VNCISCONNECTED=1 Then
			gui_connection_started()

		ElseIf $STAT_VNCISCONNECTED=0 Then
			gui_connection_ended()

		EndIf
		$LAST_ADLIB_CONNECTION=$STAT_VNCISCONNECTED
	EndIf

;~	 	if $OPTION_DEBUG=1 and $LAST_DEBUG_OPTION=0 Then
;~ 		_ConsoleWrite("Show Debug Window")
;~ 		$LAST_DEBUG_OPTION=1
;~ 	elseif $OPTION_DEBUG=0 and $LAST_DEBUG_OPTION=1 Then
;~ 		WinSetState("[REGEXPTITLE:"&@ScriptName&"; CLASS:ConsoleWindowClass]","",@SW_HIDE)
;~ 		_ConsoleWrite("Hide Debug Window")
;~ 		$LAST_DEBUG_OPTION=0
;~ 	endif
endfunc
;====================================================================================================================================
Func gui_connection_started()
	_ConsoleWrite("Function - GUI Connection Started")
	GUICtrlSetState($MW_INPUT1,$GUI_HIDE)
	GUICtrlSetState($MW_INPUT2,$GUI_HIDE)
;	GUICtrlSetState($MW_LABEL1,$GUI_HIDE)

	_ConsoleWrite("Updating GUI")
	Local $pos=ControlGetPos ($TITLE_ADVANCED,"","[CLASSNN:Edit2]");
	GUICtrlSetPos ($MW_INPUT3,$pos[0],$pos[1]-23)

	Local $pos=ControlGetPos ($TITLE_ADVANCED,"","[CLASSNN:Button1]")
	GUICtrlSetPos ($MW_BUTTON1,$pos[0]+50,$pos[1])

	Local $pos=ControlGetPos ($TITLE_ADVANCED,"","[CLASSNN:Button2]")
	GUICtrlSetPos ($MW_BUTTON2,$pos[0],$pos[1]-23)


	_ConsoleWrite($OPTION_WINDOW,1)
	Switch $OPTION_WINDOW
		Case 1, 2
			Local $pos=WinGetPos ($TITLE_ADVANCED)
			;_ConsoleWrite($pos[0]&" "&$pos[1]&"  "&$pos[2]&"x"&$pos[3])
			WinMove ($TITLE_ADVANCED,"",$pos[0],$pos[1],$pos[2]+50,$pos[3]-24,5)

		Case 3
			Local $pos=WinGetPos ($TITLE_ADVANCED)
			WinMove ($TITLE_ADVANCED,"",5,-42,$pos[2]+71,$pos[3]-24,5)

	EndSwitch

	GUICtrlSetData ($MW_BUTTON1,"End")
	_ConsoleWrite(" Done",1)

EndFunc
;====================================================================================================================================
Func gui_connection_ended()
	_ConsoleWrite("Function - GUI Connection Ended")
	GUICtrlSetState($MW_INPUT1,$GUI_SHOW)
	GUICtrlSetState($MW_INPUT2,$GUI_SHOW)
;	GUICtrlSetState($MW_LABEL1,$GUI_SHOW)

	Local $pos=ControlGetPos ($TITLE_ADVANCED,"","[CLASSNN:Edit2]")
	GUICtrlSetPos ($MW_INPUT3,$pos[0],$pos[1]+23)

	Local $pos=ControlGetPos ($TITLE_ADVANCED,"","[CLASSNN:Button1]")
	GUICtrlSetPos ($MW_BUTTON1,$pos[0]-50,$pos[1])

	Local $pos=ControlGetPos ($TITLE_ADVANCED,"","[CLASSNN:Button2]")
	GUICtrlSetPos ($MW_BUTTON2,$pos[0],$pos[1]+23)

	Switch $OPTION_WINDOW
		Case 1, 2
			Local $pos=WinGetPos ($TITLE_ADVANCED)
			WinMove ($TITLE_ADVANCED,"",$pos[0],$pos[1],$pos[2]-50,$pos[3]+24,5)

		Case 3
			Local $pos=WinGetPos ($TITLE_ADVANCED)
			WinMove ($TITLE_ADVANCED,"",100,100,$pos[2]-71,$pos[3]+24,5)

	EndSwitch

	GUICtrlSetData ($MW_BUTTON1,"Connect")

EndFunc
;====================================================================================================================================
Func tray_open_temp_folder()
	ShellExecute ($APPDIR)
EndFunc
Func tray_open_current_folder()
	ShellExecute (@ScriptDir)
EndFunc
func tray_about()
	Run(@AutoItExe & ' /AutoIt3ExecuteLine "msgbox(64,''About TeamMC UVNC-Helper'',''UVNC-Helper By TeamMC''&@CRLF&''Version: '&$VERSION_O&'''&@CRLF&''www.teammc.cc/uvnc''&@CRLF&@CRLF&''Uses UltraVNC''&@CRLF&''Version: '&$APPVER&'''&@CRLF&''www.uvnc.com'')"')
endfunc
func tray_site()
	;_IECreate ($OPTION_SITE,0,1,0,1)
	;run($OPTION_SITE)
	Run(@ComSpec & " /c " & " start " &$OPTION_SITE, "", @SW_HIDE)
EndFunc

Func tray_exit()
	Exit
EndFunc
;====================================================================================================================================
Func OnAutoItExit()
	_ConsoleWrite("Function - user exit")
	$STAT_EXITING=1

	connection_stop()

	_ConsoleWrite("Cleaning Temporary Files...")
	If FileExists ($APPDIR)=1 Then
		DirRemove($APPDIR,1)
		Sleep(700)
		If FileExists ($APPDIR)=1 Then
			_ConsoleWrite(" Cleaning Failed",1)
		Else
			_ConsoleWrite(" Cleaning Successful",1)
		EndIf
	Else
		_ConsoleWrite(" Nothing To Clean",1)
	EndIf

	Exit
EndFunc
;====================================================================================================================================
Func connection_stop()
	_ConsoleWrite("Function - connection stop")

;~ 	if $STAT_DISABLEDSECUREDESKTOP=1 then
;~ 		if RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop","REG_DWORD","1")=0 Then
;~ 			msgbox(16+262144,$TITLE,"WARNING! Please be aware and/or notify the support person that for an unknown reason the UAC secure desktop was not turned back on.")
;~ 		endif
;~ 	EndIf

	ProgressOn($TITLE,"Ending Connection","Killing connection")
	Run("""" & $APPEXEFULL & """ -kill",$APPDIR, @SW_HIDE)

	ProgressSet(30,"Waiting...")
	if $STAT_STARTEDACONNECTION=1 then Sleep(2000)
	$STAT_VNCISCONNECTED=0

	ProgressSet(50,"Removing Service")
	service_stop()

	ProgressSet(80,"Waiting...")
	ProcessWaitClose($APPEXE,3)

	If $STAT_STOPPEDUVNCSERVICE=1 And _ServiceExists(@ComputerName,"uvnc_service")=1 And _ServiceRunning(@ComputerName,"uvnc_service")=0 Then
		ProgressSet(90,"Starting Original Service...")
		_ConsoleWrite("Starting Original uvnc_service")
		If _StartService(@ComputerName,"uvnc_service")=0 Then _ConsoleWrite("Failed To Start Service")
	EndIf

	ProgressOff()
EndFunc
;====================================================================================================================================
Func connection_start()
	_ConsoleWrite("Function - connection start")
	Local $prompt, $reconnect, $run, $host, $id, $port

	$host=GUICtrlRead($MW_INPUT1)
	$port=GUICtrlRead($MW_INPUT2)

	if _sini($MULTIHOST_CONVERT,$host)<>"" Then $host=_sini($MULTIHOST_CONVERT,$host);check to see if an alias exists
	if stringright($host,4)=="VOID" or $host="" then return 0 ; Deal with port later by check for :

	ProgressOn($TITLE,"Starting Connection","Checking for existing service")
	If (_ServiceExists(@ComputerName,"uvnc_service")=1 And _ServiceRunning(@ComputerName,"uvnc_service")=1) OR (_ServiceExists(@ComputerName,"VNC server")=1 And _ServiceRunning(@ComputerName,"VNC server")=1) Then
		_ConsoleWrite("Stopping Existing uvnc_service")
		ProgressSet(30,"Stopping existing service")
		If _StopService(@ComputerName,"uvnc_service")=0 And _StopService(@ComputerName,"VNC server")=0 Then
			_ConsoleWrite("Error Stopping Service")
		Else
			$STAT_STOPPEDUVNCSERVICE=1
			Sleep(2000)
		EndIf
	EndIf

	ProgressSet(40,"Checking for existing proccesses")
	If ProcessExists("winvnc.exe") Then
		_ConsoleWrite("Stopping Existing Proccesses")
		ProcessWaitClose("winvnc.exe",2)
		ProcessWaitClose("winvnc.exe",2)
	EndIf

;~ 	if $OPTION_R1=1 And IsAdmin() then
;~ 		if RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop")="1" then
;~ 			if RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop","REG_DWORD","0")=1 then
;~ 				$STAT_DISABLEDSECUREDESKTOP=1
;~ 			endif
;~ 		endif
;~ 	endif

	if $OPTION_DSM=1 Then
		IniWrite($APPINIFULL,"admin","DSMPlugin","MSRC4Plugin_NoReg.dsm")
		IniWrite($APPINIFULL,"admin","UseDSMPlugin","1")
		if $OPTION_RC4<>"" Then
			$hand=fileopen($APPDIR&"\RC4.key",2+8+16)
			filewrite($hand,$OPTION_RC4)
			FileClose($hand)
		endif

	Else
		IniWrite($APPINIFULL,"ultravnc","passwd",$OPTION_PASS)
	endif

	IniWrite($APPINIFULL,"admin","DSMPlugin","MSRC4Plugin_NoReg.dsm")

	Select
		Case _
		($OPTION_SERVICE=1 And IsAdmin() And @OSBuild>=6000) OR _ ;And RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop")="1") OR _ ; Service If Vista And Admin & UAC
		($OPTION_SERVICE=2 And IsAdmin() And @OSBuild>=6000) OR _ ; Service If Admin & Vista
		($OPTION_SERVICE=3 And IsAdmin()) OR _ ; Service If Admin
		$OPTION_SERVICE=4 ;Force Service
			ProgressSet(50,"Starting In Service Mode ("&$OPTION_SERVICE&")")
			_ConsoleWrite("Starting Service In Mode "&$OPTION_SERVICE)
			service_start()

			if $OPTION_RECONNECT=1 then $reconnect=" -autoreconnect"


		;Case $OPTION_SERVICE=5; (Force User) Just use ELSE

		Case Else
			ProgressSet(65,"Starting In User Mode ("&$OPTION_SERVICE&")")
			_ConsoleWrite("Starting In User Mode ("&$OPTION_SERVICE&")")

			If $OPTION_PROMPT=1 Then $prompt=" -sc_prompt"

			If $OPTION_RECONNECT=1 Then
				$reconnect=" -autoreconnect"
			elseif $OPTION_RECONNECT=0 Then
				$reconnect=" -sc_exit"
			EndIf

			$run=" -run"
	EndSelect

	ProgressSet(90,"Starting connection")
	_ConsoleWrite("Starting Connection")

	If StringInStr($host,"ID:") Then; if a repeater id was apart of the host address
		$id=" -ID:"&StringMid($host,StringInStr($host,"ID:")+3)
		$host=StringStripWS(StringLeft($host,StringInStr($host,"ID:")-1),1+2)
	EndIf

	If StringInStr($host,":") Then;If port was apart of the host address we will use that
		$port=StringMid($host,StringInStr($host,":")+1)
		_ConsoleWrite("Port override: "&$port)
		$host=StringStripWS(StringLeft($host,StringInStr($host,":")-1),1+2)
	endif

	if StringInStr($host,"[") OR StringInStr($host,"]") OR StringInStr($host,":") then
		ProgressOff()
		msgbox(262144,$TITLE,"Address Error")
		return 0
	EndIf

	$RUNLINE="""" & $APPEXEFULL & """"&$prompt&$reconnect&$id&" -connect "&$host&":"&$port&$run
	_ConsoleWrite($RUNLINE)
	Run($RUNLINE,$APPDIR,@SW_HIDE)
	$STAT_STARTEDACONNECTION=1
	$STAT_VNCISCONNECTED=1

	ProgressOff()
EndFunc
;====================================================================================================================================
Func service_start()
	_ConsoleWrite("Function - service start")

	;Is it already installed?
	If _ServiceExists(@ComputerName, $sServiceName)=0 Then
		_ConsoleWrite("Installing Service")
		If _CreateService("",$sServiceName,$sServiceName,""""&$APPEXEFULL&""" -service","LocalSystem","",$SERVICE_WIN32_OWN_PROCESS,$SERVICE_DEMAND_START)=0 Then
			_ConsoleWrite("Error Creating Service")
		EndIf

		;Test Code For Using SC uvnc
		;If _CreateService("",$sServiceName,$sServiceName,""""&$APPEXEFULL&""" -connect 192.168.0.1","LocalSystem","",BitOR($OPTION_SERVICE_WIN32_OWN_PROCESS,$OPTION_SERVICE_INTERACTIVE_PROCESS),$OPTION_SERVICE_DEMAND_START)=0 Then
		;	_ConsoleWrite("Error Creating Service")
		;EndIf
	EndIf

	;Is it already running?
	If _ServiceRunning(@ComputerName, $sServiceName)=0 Then
		_ConsoleWrite("Starting Service")
		If _StartService(@ComputerName, $sServiceName)=0 Then _ConsoleWrite("Failed To Start Service")

		_ConsoleWrite("Waiting For Service To Start")
		For $i=0 To 5
			Sleep(1000)
			If _ServiceRunning(@ComputerName, $sServiceName)=1 Then ExitLoop
		Next
		If $i>5 Then _ConsoleWrite(" (Timeout)",1)

		;Run("""" & $APPEXEFULL & """ -servicehelper", "", @SW_HIDE) ;Doesnt work, service starts a helper anyway (might work anyway, but too messy, tooo many starting proccesses)

		_ConsoleWrite("Waiting For Helper")
		If _proc_waitnew($APPEXE,10000)=0 Then _ConsoleWrite(" (Timeout)",1)

		_ConsoleWrite("Static Sleep")
		Sleep(2000)
	EndIf
EndFunc
;====================================================================================================================================
Func service_stop()
	_ConsoleWrite("Function - service stop")

	If _ServiceExists(@ComputerName, $sServiceName)=1 Then
		If _ServiceRunning(@ComputerName, $sServiceName)=1 Then
			_ConsoleWrite("Service Stopping")
			If _StopService(@ComputerName,$sServiceName)=0 Then _ConsoleWrite("Failed To Stop Service")
			Sleep(100)
		Else
			_ConsoleWrite("Service Isnt Running")
		EndIf

		_ConsoleWrite("Uninstalling Service")
		If _DeleteService("",$sServiceName)=1 Then
			_ConsoleWrite("Waiting For Proccesses To Close")
			ProcessWaitClose ($APPEXE,3)
			Sleep(50)
			ProcessWaitClose ($APPEXE,3)
			Sleep(50)
			ProcessWaitClose ($APPEXE,3)

		Else
			_ConsoleWrite("Error Deleting Service")
		EndIf
	Else
		_ConsoleWrite("Service Does Not Exist")
	EndIf

EndFunc
;====================================================================================================================================
Func file_install()
	_ConsoleWrite("Function - file install")
	If Not FileExists($APPINIFULL) Or Not FileExists($APPEXEFULL) Or IniRead($APPINIFULL,"admin","auvncversion","")<>$VERSION Then
		_ConsoleWrite("Clearing And Making Temp Directory - ")
		_ConsoleWrite(DirRemove ($APPDIR,1),1)
		_ConsoleWrite(FileDelete($APPDIR),1)
		Sleep(100)
		_ConsoleWrite(DirCreate ($APPDIR),1)
		Sleep(100)

		_ConsoleWrite("Extracting Files - ")

		_ConsoleWrite(FileInstall ("winvnc.bat",$APPDIR&"\winvnc.bat",1),1)

		;FileInstall ("winvnc_sc.exe",$APPEXEFULL,1)
		;FileInstall ("winvnc.exe",$APPEXEFULL,1)
		_ConsoleWrite(FileInstall ("winvnc_autoit.exe",$APPEXEFULL,1),1)
		_ConsoleWrite(FileInstall ("ultravnc.ini",$APPINIFULL,1),1)

		;FileInstall ("SCHook.dll",$APPDIR&"\SCHook.dll",1)
		_ConsoleWrite(FileInstall ("MSRC4Plugin_NoReg.dsm",$APPDIR&"\MSRC4Plugin_NoReg.dsm",1),1)


		;FileInstall ("winvnc.zip",$APPDIR&"\UVNC.zip",1)
		;FileInstall ("winvnc_slim.zip",$APPDIR&"\UVNC.zip",1)
		;FileInstall ("winvnc_sc.zip",$APPDIR&"\UVNC.zip",1)

		;_ConsoleWrite("Unzipping")
		;_Zip_UnzipAll($APPDIR&"\UVNC.zip",$APPDIR,0)
		;If @error Then
		;	_ConsoleWrite("Failed")
		;	MsgBox(0,"Error","Extraction Failed")
		;EndIf

		_ConsoleWrite("Updating INI File")
		IniWrite($APPINIFULL,"admin","path",$APPDIR)
		IniWrite($APPINIFULL,"admin","auvncversion",$VERSION)
	Else
		_ConsoleWrite("File Install Not Needed")
	EndIf
EndFunc
;====================================================================================================================================
func embed()
	_ConsoleWrite("Function - embed")

	Local $Form1 = GUICreate($TITLE, 379, 290)
	Local $Group1 = GUICtrlCreateGroup("Embed Data/Settings", 4, 4, 369, 249)
	Local $Edit1 = GUICtrlCreateEdit("", 164, 184, 201, 61, BitOR($ES_AUTOVSCROLL,$ES_WANTRETURN))
	Local $TreeView1 = GUICtrlCreateTreeView(12, 20, 145, 225, BitOR($TVS_HASBUTTONS,$TVS_HASLINES,$TVS_LINESATROOT,$TVS_DISABLEDRAGDROP,$TVS_SHOWSELALWAYS,$WS_GROUP,$WS_TABSTOP,$WS_BORDER))
	Local $TreeView1_0 = GUICtrlCreateTreeViewItem("URL Enabled", $TreeView1)
	Local $TreeView1_1 = GUICtrlCreateTreeViewItem("Local Only", $TreeView1)
	Local $Group2 = GUICtrlCreateGroup("Description", 164, 16, 201, 164)
	Local $Label1 = GUICtrlCreateLabel("", 172, 32, 184, 144)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $Button1 = GUICtrlCreateButton("Make URL", 8, 260, 75, 25)
	Local $Button2 = GUICtrlCreateButton("Save Exe", 104, 260, 75, 25)
	Local $Button3 = GUICtrlCreateButton("Save", 200, 260, 75, 25)
	Local $Button4 = GUICtrlCreateButton("Cancel", 292, 260, 75, 25)

	$i=1
	while IsDeclared("OPTION_"&$i&"_SHORT")
		Assign("TreeView1_URL_"&$i,GUICtrlCreateTreeViewItem(_StringProper(Eval("OPTION_"&$i&"_SHORT")), $TreeView1_0))
		Assign("OPTION_TEMP_"&$i,Eval("OPTION_"&Eval("OPTION_"&$i&"_SHORT")))
		$i=$i+1
	wend

	$TreeView_RC4=GUICtrlCreateTreeViewItem("RC4Key File", $TreeView1_1)
	$TreeView_IMAGE=GUICtrlCreateTreeViewItem("Image File", $TreeView1_1)

	GUISetState(@SW_SHOW)

	Local $current_item, $file_hand, $file_data, $save_retun
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $Button4 ;Cancel=====
				GUIDelete()
				return 1

			Case $Button1;MakeURL=======================
				GUISetState(@SW_HIDE)

				local $new_url="?s=embed&"
				$i=1
				while IsDeclared("OPTION_"&$i&"_SHORT");
					if Eval("OPTION_TEMP_"&$i)<>Eval("OPTION_DEFAULT_"&$i) Then $new_url=$new_url&StringLower(Eval("OPTION_"&$i&"_SHORT"))&"="&Eval("OPTION_TEMP_"&$i)&"&"
					$i=$i+1
				wend

				if stringright($new_url,1)="&" then $new_url=stringtrimright($new_url,1)

				$URL_Form1 = GUICreate($TITLE, 689, 82)
				$URL_Input1 = GUICtrlCreateInput($new_url, 4, 28, 677, 21)
				;$URL_Button1 = GUICtrlCreateButton("Copy to Clipboard", 500, 52, 99, 25)
				$URL_Button2 = GUICtrlCreateButton("Ok", 604, 52, 75, 25)
				GUISetState(@SW_SHOW)

				While 1
					$nMsg = GUIGetMsg()
					Switch $nMsg
						Case $GUI_EVENT_CLOSE, $URL_Button2
							GUIDelete($URL_Form1)
							GUISetState(@SW_SHOW,$Form1)
							ExitLoop
					EndSwitch
				WEnd

			Case $Button2;Save Exe======================
				GUISetState(@SW_HIDE)

				local $new_embed_data="<TEAMMCDATA=STARTDATA>LOCAL", $new_embed_data_end="<TEAMMCDATA=ENDDATA>", $embeded_anything=0
				$i=1
				while IsDeclared("OPTION_"&$i&"_SHORT");
					if Eval("OPTION_TEMP_"&$i)<>Eval("OPTION_DEFAULT_"&$i) Then
						$new_embed_data=$new_embed_data&"<TEAMMCDATA="&StringUpper(Eval("OPTION_"&$i&"_SHORT"))&">"&Eval("OPTION_TEMP_"&$i)
						$embeded_anything=1
						_ConsoleWrite("Set Option "&Eval("OPTION_"&$i&"_SHORT")&" To "&Eval("OPTION_TEMP_"&$i))
					Else
						_ConsoleWrite("Leaving Option "&$i&" Blank Because Default ("&Eval("OPTION_DEFAULT_"&$i)&")")
					endif
					$i=$i+1
				wend

				$file_hand=FileOpen(@AutoItExe,16)
				$file_data=FileRead($file_hand)
				FileClose($file_hand)

				If $STAT_FOUNDEMBEDDATA=1 Then
					$file_data=BinaryToString($file_data)
					$file_data=StringLeft($file_data,$EMBED_DATA_START-StringLen("<TEAMMCDATA=STARTDATA>")-1)
					$file_data=StringToBinary($file_data)
					_ConsoleWrite("Found previously embed data and will use the first: "&$EMBED_DATA_START)
				endif

				if $OPTION_RC4<>"" then $OPTION_RC4="<TEAMMCDATA=RC4>"&$OPTION_RC4
				if $OPTION_IMAGE<>"" then $OPTION_IMAGE="<TEAMMCDATA=IMAGE>"&$OPTION_IMAGE
				if $embeded_anything=0 then
					$new_embed_data=""
					$new_embed_data_end=""
				EndIf

				$new_embed_data=StringToBinary($new_embed_data&$OPTION_IMAGE&$OPTION_RC4&$new_embed_data_end)

				$new_file_name=StringLeft(@ScriptName,StringInStr(@ScriptName,".",0,-1)-1)&"_NEW.exe"
				$new_file_full=FileSaveDialog ($TITLE,@ScriptDir,"Executable files (*.exe)",16+2,$new_file_name)
				If @error Then
					GUISetState(@SW_SHOW)
					ContinueLoop
				EndIf
				_ConsoleWrite("0")
				$file_hand=FileOpen($new_file_full,2+16)
				_ConsoleWrite("1")
				$save_return=FileWrite($file_hand,$file_data&$new_embed_data)
				_ConsoleWrite("2")
				FileClose($file_hand)

				If $save_return=0 then;OR Abs(FileGetSize($new_file_full)-FileGetSize($APPEXEFULL))>100000
					If MsgBox(5+48,$TITLE,"File could not be saved.")=4 Then
						GUISetState(@SW_SHOW)
						ContinueLoop
					Else
						GUIDelete()
						Return 0
					EndIf
				Else

					if MsgBox(1,$TITLE,"File was saved successfully. Press Ok to exit or Cancel to return to the program")<>2 then exit
				EndIf

				GUIDelete()
				Return 1

			Case $Button3;Save=========================
				$i=1
				while IsDeclared("OPTION_"&$i&"_SHORT");
					Assign("OPTION_"&Eval("OPTION_"&$i&"_SHORT"),Eval("OPTION_TEMP_"&$i))
					$i=$i+1
				wend
				GUIDelete()
				Return 1

		EndSwitch

		$found_id=0
		$tree=GUICtrlRead($TreeView1);get currently selected list item id
		$i=1
		while IsDeclared("OPTION_"&$i&"_SHORT");check all list item id's
			if Eval("TreeView1_URL_"&$i)=$tree then; do if checked id is selected id
				$found_id=1
				if $current_item<>$tree then;The current item has changed

					$display=Eval("OPTION_TEMP_"&$i);Set to temp
					;if @error then $display=Eval("OPTION_"&Eval("OPTION_"&$i&"_SHORT"));Set to global if temp doesnt exist

					GUICtrlSetData($Label1,Eval("OPTION_"&Eval("OPTION_"&$i&"_SHORT")&"_DESC"));Display desc
					GUICtrlSetData($Edit1,$display);Display set data
					$current_item=$tree; change the current item status

				Else;The current item is still selected
					Assign("OPTION_TEMP_"&$i,GUICtrlRead($Edit1))

				endif
			endif
			$i=$i+1
		wend
		if $found_id=0 And GUICtrlRead($Label1)<>"No option selected" then
			GUICtrlSetData($Label1,"No option selected");Display desc
			GUICtrlSetData($Edit1,"");Display set data
		endif

		switch $tree
			case $TreeView_RC4
				if $OPTION_RC4<>"" then msgbox(0,$TITLE,"This Options apears to already be set. Pressing cancel on the next screen will leave the option at its previous value, selecting a new value will overwrite it.")
				$open_file=FileOpenDialog ($TITLE,@ScriptDir, "All (*.*)",1+2)
				if @error<>1 then
					$hand=fileopen($open_file,16)
					$data=fileread($hand)
					FileClose($hand)
					$OPTION_RC4=$data
				endif
				GUICtrlSetState ($TreeView1_1,$GUI_FOCUS)

			case $TreeView_IMAGE
				if $OPTION_IMAGE<>"" then msgbox(0,$TITLE,"This Options apears to already be set. Pressing cancel on the next screen will leave the option at its previous value, selecting a new value will overwrite it.")
				$open_file=FileOpenDialog ($TITLE,@ScriptDir, "All (*.*)",1+2)
				if @error<>1 then
					$hand=fileopen($open_file,16)
					$data=fileread($hand)
					FileClose($hand)
					$OPTION_IMAGE=$data
				endif
				GUICtrlSetState ($TreeView1_1,$GUI_FOCUS)

		EndSwitch

		sleep(10)
	WEnd

	return 0
endfunc

