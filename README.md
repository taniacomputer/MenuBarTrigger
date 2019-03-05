# MenuBarTrigger
## macOS command line utility for displaying a menubar item with a popover web view, while simultaneously running a process
It is written in Swift 3 and has been testedd and confirmed to work on macOs 10.12.6 up to 10.14.3

[You can get the latest pre-built MenuBarTrigger pkg from here](https://s3.amazonaws.com/taniacomputer/MenuBarTrigger+v1.1.pkg) (pkg installs MenuBarTrigger.app in /usr/local) 

## Usage: 

>MenuBarTrigger.app/Contents/MacOS/MenuBarTrigger WEBVIEW_1 COMMAND_1 WEBVIEW_2 COMMAND_2 ... [OPTIONS]

MenuBarTrigger displays a webView pop-over while simultaneously executing a command. Once the command
finishes executing MenuBarTrigger moves on to the next webView/command pair.

### WEBVIEW
The local HTML file or HTML string to display
-f, --file <path to file>
OR
-html, --html <HTML string>

### COMMAND
The command to execute. Command can be a shell command or a jamf binary command.

**Example shell commands:**
'sleep 5'

'/tmp/a_script.sh'

"/usr/sbin/installer -package '/tmp/CocoaDialog v2.1.1.pkg' -target /"

Note the single quotes to wrap around the filename with spaces.

**Accepted jamf commands:**
All jamf verbs, although be warned that MenuBarTrigger has only been tested with jamf binary versions 9.61 - 9.97, so far.
Note: MenuBarTrigger assumes that the binary is in /usr/local/bin/jamf. Specify fullpath if you relocated the binary.
MenuBarTrigger needs to be run as root to run jamf commands.

**Example jamf commands:**
>"policy -trigger 'microsoft office'"

>"policy -trigger vlc"

>"recon"

**There is one special MenuBarTrigger commands: wait**

wait displays the webView until a particular link on the presented HTML.

MenuBarTrigger.app/Contents/MacOS/MenuBarTrigger WEBVIEW wait 

What occurs once the link is clicked depends on the url:
- A link to "next", eg. <a href="http://next">NEXT</a>, makes MenuBarTrigger proceed to the next web view/command pair.
- A link to "formParse", eg. <a href="http://formParse">Submit</a>, will inspect any form values and return the results to stdout. before proceeding to the next web view/command pair.
- A link to "quit", eg. <a href="http://quit">Done</a>, terminates MenuBarTrigger.
Be sure to add http:// in the link URL (required by macOS 10.12.4+)

### COMMAND --icon <Path to image file>
Changes the menubar icon at the same time as the command is being run.
Icon image file should be .png format and 16x16px in size.

### COMMAND,NAME
If an output file is specified (see '-o, --output' option below), all named commands
have their stdout and success status written to this file.
A command is named by appending a comma followed by the name in quotations.
eg. "policy -trigger mcafee","McAfee Security Agent"

### OPTIONS
**--icon <Path to image file>**
Sets menubar icon.
Icon file should be .png format and 16x16 pixels in size.
If this option is not set then the MenuBarTrigger icon is displayed instead.

**-h, --height <window height>**
Height, in pixels, of content window.
Must be within the minimum and maximum height of the content window.
The range for this display is 20 - 701 pixels.
Default height is 420px.

**-w, --width <window width>**
 Width, in pixels, of content window.
Must be within the minimum and maximum width of the content window.
The range for this display is 20 - 801 pixels.
Default width is 420px.
