# Simple UVNC
A simple way for the people you support to establish a reverse VNC connection to a VNC viewer in listen mode.

## Downloads
Latest Beta Release: [4.0.0 Build: ?](http://teammc.cc/uvnc/UVNC-Helper-Beta.exe) (.exe)  
Latest Stable Release: [3.1.5](http://teammc.cc/uvnc/UVNC-Helper.exe) (.exe)

## About
This project is an AutoIT script that wraps itself around UVNC, it uses and manipulates UVNC in a easy to 
use manner and adds extra functionality to make simple tasks... simple, here are some key features:

* Establishes a reverse connection to a listening viewer
* Size: ~595KB
* 100% contained within a single executalbe, no compiling or config files
* Uses a slimed version of UVNC winvnc.exe (1.0.6.3)
* Runs winvnc.exe in service mode or user mode automaticly to maximize stability and to increase Vista UAC support
* Uses customizable embeded data in the executable to save your host, port and many more options
* Command system to quickly execute simple tasks without a lot of GUI interaction so things are easy on slow connections.
* Special custom commands to download and run your own applications.

## Instructions

### Command Line
UVNC-Helper has a command line interpreting routine that will allow the easy addition of commands/switches to make this program more powerfull. Default commands are listed here.

* -connect [host[:port]]  Connects to a listening viewer, if host or host/port are not specified then its asumed that the host or host/port have been saved in the executable using EmbedData.

### Application Commands
The main GUI has an input field to run special commands/actions using a built in routine that can be expanded upon. Default commands are listed here.

* embed    Special command to edit all the embed properties of the executable, ie: host, port, window title
* vnc <command-line>    Executes winvnc.exe with whatever commandline you specify.	
* cmd <command-line>    Execute a regular command at the command prompt.
* reset <seconds>    Disconnects the UVNC session and then reconnects after specified seconds.
* set <option> <value>	    Sets the specified option to specified value, these are the options that are listed in the embed help file. Changing some value on the fly will have no effect.

### Options & Embed Data
The embed data feature stores customizable data in the executable so that you can have a single executable file with all your saved options, there are two ways to embed data:

1. Use the built in command 'embed', this will open a window that lets you change all values and then save your new executable.
2. Use the AutoEmbed online scipt, using a URL with the correct values will automaticly give you a pre configured downloadable executable.

* host - The host IP or domain to be displayed in the host input by default	
	Use [friendlyname] in front of the address to use a friendly name. use a comma between addresses to specify more then one host. 
	ex: "[John]support.teammc.cc,[Allyssa]support2.teammc.cc"
	
* port - The port number to be displayed in the port input by default (Defaut: 5500)
* title - The title to be displayed in the window title bar

* service - Desides if UVNC will run as a service or as the user	
	1=Runs as service if os is vista AND user is admin. (Default)
	2=Deprecated, alias of value 1.
	3=Runs as service if user is admin.
	4=Runs as service.
	5=Runs as user.
	
* window - Changes the behavior of the programs main window.	
	1=Always on top, Tool window, No task bar. (Default)
	2=Normal window.
	3=UVNC/RDP style docking.

* prompt - Prompts viewer to accept connection just like the old SC. Only works when running as user. 1=Enable 0=Disable (Default).

* reconnect - If the viewer disconnects the server will automaticly try to reconnect to it. If set to "0" then the new sc_exit option will be used (user mode only).	
	1=Reconnect Automaticly. (Default)
	0=Do Nothing.
	3=(For debug - no options at all).

* dsm - Uses a DSM plugin to encrypt your connection.	
	1=MSRC4Plugin_NoReg.dsm.
	0=Disable.

* password - Pre encrypted password from your uvnc.ini file.	Leave blank to not use.	Blank

* site - URL to the support providers website, if specified a tray icon item will be available.

## Source Files & Compiling
* Getting AutoIt & Scite:
   Visit http://autoitscript.com and navigate to the AutoIt3 download section. Scroll down to the first download items "AutoIt Full Installation" and "AutoIt Script Editor." download and install these, follow any directions provided by the installation packages.
   Note: The script editor is needed to utilize all the compile directives.

* Getting the source:
   Visit https://github.com/jmclaren7/simpleuvnc

* Viewing Source/Making Adjustments:
To view the source, install AutoIT and navigate to the new folder you unziped the source to, you should be able to right click on "UVNC-Helper.au3" and click on "edit script". 

* A Note About How I Compress My Builds:
In this order, i...
*Strip winvnc.exe of extra resources that we wont use in a SingleClick - The largest side effect of this is that we loose the digital signature
*Compress winvnc.exe using PECompact2 with lzma2 method set to highest compresion. - Anytime a executable is compacted it increases the chance of AV programs creating a false virus detection.
*Compile the autoit script (packs winvnc.exe within the script) with Obfuscator set to /StripOnly and upx off.
*Compress the compiled script using PECompact2 using same settings as above. 

## Changes
	* 4.0.0
		* Changed: Seperate/New GUIs for initial screen and connected screen
		* Changed: Uses slimed version of UVNC 1.0.8.2
		* Changed: when using embed option "embed" as a password, you are now prompted for the password in the final exe after typing "embed"
		* Added: Tray menu option to open the current app folder, usefull if downloaded to a temp folder.

	* 7-12-09 - 3.1.5.0
		* Fixed: Description of the embed command
		* Fixed: Error on connection when using 'lock' option
		* Note: Using UVNC 1.0.6.3 (since 3.1.0.36)
		* Added: Embed option "embed" to protect the executable from accessing the embed screen
		* Fixed: DSM file wasnt being packed with the executable because of tests i was conducting
		* Fixed: Command line -connect not working when ip/port is secified
		* Fixed: Having the port included as part of the host field wasnt overriding the number in the port field (aka ports included with friendly names or command line were not working)
		* Fixed: Possible coruption in winvnc.exe from reshacking
		* Added: Embed option "lock" to prevent editing of host/port 0=allow both 1=lock both 2=lock host only 3=lock port only
		* Changed: Multiple host seperator character changed from "," to ";"
		* Changed: Changed the way the embed option "site" works, it will now execute a command at the command prompt using the windows cmd.exe "start"
			directive, if you specifiy a URL with a prefix thats properly set by your browser like "http://" then this will open it in that default browser
		* Changed: New embed/settings dialog and backend.
		* Added: Make URL option in embed dialog
		* Added: "Save" option in embed window will only update the currenlty loaded settings (many changes are not noticable by doing this)
		* Added: Ability to add a non selectable host list item by adding a friendly name with no value, ex: [Please Select A Tech];[John]192.168.0.1;[--Alternative Techs--];[Allyssa]host2.teammc.cc
		* Note: Changes will only be available in the changelog available in the SRC zip, or online documentation, and not in the UVNC-Helper.au3 source itself

	* 6-23-09 - 3.1.0.0
		* Fixed: Issue from Beta 2 that didnt allow you to embed data in a previously embeded executable
		* Changed: Uses slimed version of UVNC 1.0.6.1
		* Changed: Embed option "confirm" is now "prompt" to maintain consistancy with UVNC and this option no longer has prerequisite regarding option "reconnect"
		* Changed: Embed option "reconnect" set to "0" will enable "autoexit", set to "1" (default) will enable "autoreconnect"
		* Changed: Re built the system to read/write embed data to allow for binary data/large strings
		* Changed: Re built php embed script to work with this new method (no cross compatibility, so it wont be published untill we release)
		* Changed: New embed system makes only "non-default" data get embeded
		* Changed: Tray icon title is window title
		* Changed: Service Mode 1 & 2 are now functionally the same, they both work as mode 2, seems i didnt understand that if the UAC secure desktop was disabled you still cant interact with the UAC prompt
		* Added: Embed Option "RC4 Key File Select", select an rc4 key file from the embed screen, this cant be done with a URL
		* Added: Embed Option "Password" (Pre-Encrypted), add a pre encrypted password (from uvnc ini file) to set in ini file at runtime
		* Added: Embed option "site" for adding a tray item to visit the supporters website, site=http://teammc.cc (Empty by default)
		* Added: Embed option "dsm" for using DSM plugins, 0=disabled 1=MSRC4Plugin_NoReg, disabled by default
		* Added: Winvnc.exe version 1.0.6.0
		* Added: "About" dialog in tray menu
		* Added: If host input includes port (ie "192.168.0.1:5500"), it will override the number in the port input
		* Added: User configured host dropdown, usage: host=192.168.0.1,teammc.cc,78.253.87.43:5500 (comma seperated)
		* Added: Repeater ID Option, In the host input add "ID:xxxx" ie.. "192.168.0.1 ID:1234", this will be undocumented because it could change in the next version
		* Added: Host aliases, possible way to set host: "[Server]192.168.0.1,[Joe]teammc.cc ID:8902,56.49.100.2,[Bill]192.168.0.1:4400
		* Added: Command "set" to set any embed option on the fly, please note that some values like Title wont apear to change especialy on the main window
		* Added: Command "set2" this command will set any program variable, it will remain undocumented and is for dev/debug only
		* Added: Embed option "debug"
		* Fixed: Error displays when an aptget package doesnt exist
		* Fixed: Main window wouldnt resize on connect unless it was in focus
		* Fixed: Command line parameters with a value were not being understood all the time
		* Fixed: System for hiding text in command input wouldnt allow you delete all the text in the box under some circumstances
		* Fixed: Sperating command & data wasnt reliabe or consistant
		* Fixed: Adds check for old service name "VNC service"
		* Fixed: Exit speed (we still try to kill a connection but we dont wait for it if we never started one in the first place)
		* Note: Command "service" replaced by "set service"
		* Note: Command "debug" repaced by "set debug"
		* Note: Pushed back connect after reboot to next feature update
		* Note: Added notes to the top of UVNC-Helper.au3 about compiling with autoit
		* Note: Re-enabled "Only Instance" for release

	* 6-11-09 - 3.0.1.0
		* Fixed: Wasnt handling settings "reconnect" and "confirm" correctly

	* 6-04-09 - 3.0.0.0
		* Added: If winvnc.exe exists at all it will be closed when a connection attempt is made (first we check for service)
		* Added: Tray option to open the temp folder
		* Added: Command reset now works when changes are made to the service mode during operation
		* Added: SC Connection confirmation for user mode
		* Added: Option to enable disable autoreconnect (reconnect=1) (on by default, will be ignored for user mode connection if confirm=1)
		* Added: Option to disable/enable SC connection confirmation (confirm=0) (off by default, only used for user mode, this option will override reconnect in user mode if set to 1)
		* Added: Connection Timer
		* Added: Ping Display
		* Added: Command line interpreting system for future command line options
		* Added: Command line argument ( -connect [host[:port]] )   if data is embeded then using -connect alone will use embeded data
		* Added: File save success/failure dialog for embed
		* Added: Aptget lister now has a space to enter parameters
		* Added: Window docking after connected, window option 3
		* Changed: Totaly recoded the connect and disconnect procedure to alow for things like the command "reset"
		* Changed: Reduced size by compressing winvnc.exe with PECompact2 externaly
		* Changed: User mode now uses -run and -connect at once
		* Changed: Service mode numbers changed, default is 1 (Service if Vista & Admin & UAC SecureDesktop On)
		* Changed: Aptget lister window size increased
		* Changed: Aptget lister window displays right away and items are then added to it (cant do anything while adding)
		* Changed: Display version number gets 0s trimmed from last 2 places
		* Changed: Added UVNC-Helper to the title
		* Changed: No longer kills another UVNC connection if you simply open UVNC-Helper and then close it
		* Changed: Exit cleaning is more aware of if server is still running, and exits sooner if its not
		* Changed: Many minor changes
		* Fixed: Aptget lister had minor display errors related to list control
		* Fixed: Aptget lister will now handle spaces in file names
		* Fixed: Aptget clearing app folder if it already exists wasnt working, would prompt for overwrite
		* Fixed: Answering no to multi instance prompt would produce error, but still exit
		* Fixed: Passing command line to aptget app would fail
		* Fixed: Exit function was called twice when exiting from the tray
		* Fixed: Many minor fixes

	*5-20-09 - 2.4.2.0
		* Fixed: Strange behavior when the normal uvnc service is running on the system (Should fix both user (multi instance error) and service mode errors)
		* Fixed: Miscellaneous issues with embed command
		* Fixed: Miscellaneous issues with exit/cleaning procedure, most notably: not killing a user mode connection
		* Changed: Uses UVNC winvnc.exe 1.0.5.7.4
		* Changed: Added filtering to the AptGet lister for hiding suffix/prefix
		* Added: Service option value 4 (Service if Vista+ & admin else user)
		* Added: Mouse over descriptions of options in the embed window
		* Added: Proggress bar for service start to remove confusion about if the program is doing anything
		* Added: AptGet app "hijackthis" - Runs, AutoScans, Opens IE Browser window and submits log at: http://hjt.networktechs.com
		* Added: AptGet lister tries to get descriptions (same file name but with .txt extention)
		* Added: Added option to prevent attempting to get AptGet app descriptions (each time a app is found we check to see if a txt file exists at the same URL)
		* Note: Unneeded embed data check when using embed command
		* Note: Deleted alot of noted out old code
		* Note: Fixed typo in version of the source code zip file


	*5-15-09 - 2.3.1.82
		* Added: Command "reset <seconds>" resets disconnects and reconnects after specified seconds
		* Added: Command aptget without parameters will attempt to list available application packages
		* Added: Command "service <#>" so that the mode can be changed at the last minute
		* Changed: AutoIt installs winvnc.exe as a service instead of it installing itself
		* Changed: Temporary directory is now uvnc_autoit
		* Changed: Service name is now uvnc_service_autoit
		* Changed: Service uninstallation runs on program exit no matter what now
		* Fixed: Working directory when winvnc.exe is executed is now the directory winvnc.exe is in
		* Fixed: Verbose for service install and start timeouts would never display
		* Documentation: Documented on the UVNC forum the rest of the built in commands
		* Note: Moved functions to main script file

	* 5-03-09 - 2.2.1.47
		* Changed: Ownerdata is now refered to as Embed Data
		* Changed: Command "aptget ownerdata" is now "embed"
		* Changed: Embed function is now built into the program (not a downloaded app)
		* Changed: No longer requiers admin, but will invoke if possible
		* Changed: Lots of changes to the code
		* Changed: ~25KB Reduction from the code related changes in this update
		* Changed: Aptget packages download into the same temporary folder as the uvnc files
		* Changed: Now uses slim winvnc.exe (1.0.5.7.1) from vnc2me.org (~210KB Reduction), Thanks JDaus!
		* Changed: winvnc.exe is no longer twice compressed (~50KB Gain) This should add support for Windows 2000 (not for aptget however)
		* Added: The temporary directory is cleaned on exit
		* Added: Save dialog for Embed
		* Added: Embed data to change the aptget repository URL (default is http://repo.teammc.cc)
		* Added: Embed data to choose what mode winvnc.exe will operate in (1=Auto (Service If Running As Admin) 2=Service 3=User)
		* Added: Generate DebugLog by executing with -debug as a command line parameter
		* Added: Command "vnc" for executing winvnc.exe directly with command parameters, good to quickly fix a forced exit while service is installed (vnc -uninstall)
		* Added: On exit, temporary directory is removed
		* Note: CRC32 checks on aptget packages
		* Fixed: Lots of small bug fixes

	* 4-12-09 - 2.1.0.353
		* Changed: Totaly changed the way ownerdata/embeded data works, MUCH MORE SIMPLE and reliable, no more ResHacker
		* Changed: Minor Bug and GUI fixes
		* Changed: Updated Video

	*4-10-09 - 2.0.0.322
		* First official release