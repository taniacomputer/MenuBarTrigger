//
//  AppDelegate.swift
//  MenuBarTrigger
//
//  Created by tania on 13/3/18.
//  Copyright © 2018 taniacomputer. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var button: NSStatusBarButton?
    var buttonPathProvided = false
    var buttonIconPath = ""
    var commandViews = [CommandView]()
    let marginWidth = 0
    var height = 420
    var width = 420
    var heightMin = 20
    var heightMax = 701
    var widthMin = 20
    var widthMax = 801
    var logPath: String? = nil
    let popover = NSPopover()
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
     
        var file:LocalWebFile = (nil, nil)
        let numberOfArguments = Int(CommandLine.argc)
        var index = 0
        while index < numberOfArguments {
            let arg = CommandLine.arguments[index]
            var jamfVerbAndName = ""
            switch arg {
            case "--file", "-f":
                if let filePath = CommandLine.arguments[index + 1] as String? {
                    
                    file = validateAndReturnLocalWebFile(filePath: filePath as NSString)
                    
                    if let verbAndName = CommandLine.arguments[index + 2] as String? {
                        jamfVerbAndName = verbAndName
                        let newCommandView = getCommandView(isFile: true, jamfVerbAndName: jamfVerbAndName)
                        newCommandView.localFile = file
                        commandViews.append(newCommandView)
                    }
                    else {
                        error(err: "No jamf command specified.")
                    }
                } else {
                    error(err: "File path not specified.")
                }
                index += 2
            case "--icon", "-i":
                if let iconPath = CommandLine.arguments[index + 1] as String? {
                    let buttonIconPath = validateAndReturnIconPath(filePath: iconPath as NSString)
                    self.buttonIconPath = buttonIconPath
                    buttonPathProvided = true
                }
                index += 1
            case "--output", "-o":
                if let logPath = CommandLine.arguments[index + 1] as String? {
                    //Check if file exists
                    if FileHandle(forWritingAtPath: logPath) != nil {
                        error(err: "\(logPath) already exists.")
                    } else {
                        self.logPath = logPath
                    }
                }
                index += 1
            case "--height", "-h":
                if let newHeight = CommandLine.arguments[index + 1] as String? {
                    if Int(newHeight) == nil {
                        error(err: "Height must be an integer value")
                    } else {
                        if Int(newHeight)! >= heightMin && Int(newHeight)! < heightMax {
                            self.height = Int(CommandLine.arguments[index + 1])!
                        } else {
                            error(err: "Height value of \(newHeight) is not within required bounds")
                        }
                    }
                }
                index += 1
            case "--width", "-w":
                if let newWidth = CommandLine.arguments[index + 1] as String? {
                    if Int(newWidth) == nil {
                        error(err: "Width must be an integer value")
                    } else {
                        if Int(newWidth)! >= widthMin && Int(newWidth)! < widthMax {
                            self.width = Int(CommandLine.arguments[index + 1])!
                        } else {
                            error(err: "Width value of \(newWidth) is not within required bounds")
                        }
                    }
                }
                index += 1
            case "--help":
                displayManPage()
            case "-NSDocumentRevisionsDebugMode":
                index += 1
                break;
            default:
                error(err: "Unknown or missing argument(s): \(arg)")
            }
            index += 1
        }
            
        let storyboard = NSStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateController(withIdentifier: "vc") as! CustomViewController
        let size = NSSize(width: CGFloat(width), height: CGFloat(height))
        
        vc.view.frame.size = size
        vc.setSubViews(webviewWidth: width, webviewHeight: height, margin: marginWidth)
        
       
        vc.setCommandViews(commandviews: commandViews)
        
        if let button = statusItem.button {
            if buttonPathProvided {
                let image = NSImage(byReferencingFile: "\(buttonIconPath)")
                    button.image = image
            } else {
                    button.image = NSImage(named: "default-icon")
            }
                
            button.action = #selector(togglePopover(_:))
            vc.button = statusItem.button
            if (logPath != nil) {
               vc.setOutputPath(logPath: logPath!)
            }
            vc.begin()
            popover.contentViewController = vc
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func quit() {
        NSApp.terminate(self)
    }
    
    func displayManPage() {
        let singleIndent="\t\t"
        let doubleIndent="\t\t\t\t"
        print("Usage: MenuBarTrigger.app/Contents/MacOS/MenuBarTrigger WEBVIEW_1 COMMAND_1 WEBVIEW_2 COMMAND_2 ... [OPTIONS]")
        print("MenuBarTrigger displays a webView while simultaneously executing a command. Once the command")
        print("finishes executing MenuBarTrigger moves on to the next webView/command pair.")
        print("")
        print("WEBVIEW")
        print("The local HTML file or HTML string to display")
        print("\(singleIndent)-f, --file <path to file>")
        print("\(singleIndent)OR")
        print("\(singleIndent)-html, --html <HTML string>")
        print("")
        print("COMMAND")
        print("The command to execute. Command can be a shell command or a jamf binary command.")
        print("\(singleIndent)Example shell commands:")
        print("\(singleIndent)\"sleep 5\"")
        print("\(singleIndent)\"/tmp/a_script.sh\"")
        print("\(singleIndent)\"/usr/sbin/installer -package '/tmp/CocoaDialog v2.1.1.pkg' -target /\"")
        print("\(singleIndent)Note the single quotes to wrap around the filename with spaces.")
        print("\(singleIndent)Accepted jamf commands:")
        print("\(singleIndent)All jamf verbs, although be warned that MenuBarTrigger has only been tested with jamf binary versions 9.61 - 9.97, so far.")
        print("\(singleIndent)Note: MenuBarTrigger assumes that the binary is in /usr/local/bin/jamf. Specify fullpath")
        print("\(singleIndent)if you relocated the binary.")
        print("\(singleIndent)MenuBarTrigger needs to be run as root to run jamf commands.")
        print("\(singleIndent)Example jamf commands:")
        print("\(singleIndent)\"policy -trigger 'microsoft office'\"")
        print("\(singleIndent)\"policy -trigger vlc\"")
        print("\(singleIndent)\"recon\"")
        print("")
        print("\(singleIndent)Check out '/usr/local/bin/jamf help' for more information on the jamf binary.")
        print("")
        print("\(singleIndent)Special MenuBarTrigger command:")
        print("\(singleIndent)wait")
        print("\(doubleIndent)Displays the webView until a special url link is clicked.")
        print("\(doubleIndent)What occurs once the link is clicked depends on the url:")
        print("\(doubleIndent)- A link to \"next\", eg. <a href=\"http://next\">NEXT</a>, makes MenuBarTrigger proceed")
        print("\(doubleIndent)to the next webView/command pair.")
        print("\(doubleIndent)- A link to \"formParse\", eg. <a href=\"http://formParse\">Submit</a>, will inspect")
        print("\(doubleIndent)any form values and return the results to stdout")
        print("\(doubleIndent)before proceeding to the next webView/command pair.")
        print("\(doubleIndent)- A link to \"quit\", eg. <a href=\"http://quit\">Done</a>, terminates MenuBarTrigger.")
        print("\(doubleIndent)Be sure to add http:// in the link. It's required by macOS 10.12.4+.")
        print("")
        print("\"COMMAND --icon <Path to image file>\"")
        print("\(singleIndent)Changes the menubar icon at the same time as the command is being run.")
        print("\(singleIndent)Icon image file should be .png format and 16x16px in size.")
        print("\"COMMAND,NAME\"")
        print("\(singleIndent)If an output file is specified (see '-o, --output' option below), all named commands")
        print("\(singleIndent)have their stdout and success status written to this file.")
        print("\(singleIndent)A command is named by appending a comma followed by the name in quotations.")
        print("\(singleIndent)eg. \"policy -trigger mcafee\",\"McAfee Security Agent\"")
        print("")
        print("OPTIONS")
        print("\(singleIndent)--icon <Path to image file>:")
        print("\(doubleIndent)Sets menubar icon.")
        print("\(doubleIndent)Icon file should be .png format and 16x16 pixels in size.")
        print("\(doubleIndent)If this option is not set then the MenuBarTrigger icon is displayed instead.")
        print("\(singleIndent)-h, --height <window height>:")
        print("\(doubleIndent)Height, in pixels, of content window.")
        print("\(doubleIndent)Must be within the minimum and maximum height of the content window.")
        print("\(doubleIndent)The range for this display is \(heightMin) - \(heightMax) pixels.")
        print("\(doubleIndent)Default height is 420px.")
        print("\(singleIndent)-w, --width <window width>:")
        print("\(doubleIndent)Width, in pixels, of content window.")
        print("\(doubleIndent)Must be within the minimum and maximum width of the content window.")
        print("\(doubleIndent)The range for this display is \(widthMin) - \(widthMax) pixels.")
        print("\(doubleIndent)Default width is 420px.")
        self.quit()
    }
    
    func isVerb(str:String) -> Bool {
        let verbs = ["about",
                     "bind",
                     "bless",
                     "checkJSSConnection",
                     "createAccount",
                     "createConf",
                     "createHooks",
                     "createSetupDone",
                     "createStartupItem",
                     "deleteAccount",
                     "deletePrinter",
                     "deleteSetupDone",
                     "displayMessage",
                     "enablePermissions",
                     "enroll",
                     "fixByHostFiles",
                     "fixDocks",
                     "fixPermissions",
                     "flushCaches",
                     "flushPolicyHistory",
                     "getARDFields",
                     "getComputerName",
                     "heal",
                     "help",
                     "install",
                     "installAllCached",
                     "listUsers",
                     "log",
                     "manage",
                     "mapPrinter",
                     "mcx",
                     "modifyDock",
                     "mount",
                     "notify",
                     "policy",
                     "reboot",
                     "recon",
                     "removeFramework",
                     "removeSWUSettings",
                     "resetPassword",
                     "runScript",
                     "runSoftwareUpdate",
                     "setARDFields",
                     "setComputerName",
                     "setHomePage",
                     "setOFP",
                     "startSSH",
                     "uninstall",
                     "unmountServer",
                     "updatePrebindings",
                     "version",
                     "sleep",
                     "wait"
        ]
        if verbs.contains(str) {
            return true
        } else {
            return false
        }
    }

    func getCommandView(isFile: Bool, jamfVerbAndName: String) -> CommandView {
        let whichJamf = "/usr/local/bin/jamf"
        let whichSleep = "/bin/sleep"
        let whichWait = "/usr/bin/wait"
        
        var taskName:String? = nil
        var jamfTask:String? = nil
        
        
        if jamfVerbAndName.contains(",") {
            let jamfVerbAndNameSplit = jamfVerbAndName.split(separator: ",").map(String.init)
            jamfTask = jamfVerbAndNameSplit[0]
            taskName = jamfVerbAndNameSplit[1]
        } else {
            jamfTask = jamfVerbAndName
            taskName = nil
        }
        
        jamfTask = jamfTask?.replacingOccurrences(of: whichJamf, with: "")
        jamfTask = jamfTask?.replacingOccurrences(of: whichSleep, with: "sleep")
        jamfTask = jamfTask?.replacingOccurrences(of: whichWait, with: "wait")
        
        let arguments:[String] = jamfTask!.split(separator: " ").map(String.init)
        var inSingleQuote = false
        var totalQuotes = 0
        var newArguments:[String] = [String]()
        var task:[String] = [String]()
        
        for word in arguments {
            
            var newWord = word
            
            if newWord.first! == "\'" {
                
                if inSingleQuote == false {
                    newWord.removeFirst()
                    inSingleQuote = true
                    totalQuotes += 1
                } else {
                    error(err: "Quotes used incorrectly.")
                }
                
                if newWord.last == "\'" {
                    newWord.removeLast()
                    inSingleQuote = false
                    totalQuotes += 1
                }
                
            } else if newWord.last == "\'" {
                if inSingleQuote {
                    newWord.removeLast()
                    inSingleQuote = false
                    totalQuotes += 1
                    
                    let lastIndex = newArguments.endIndex - 1
                    
                    newWord = "\(newArguments[lastIndex]) \(newWord)"
                    newArguments.removeLast()
                } else {
                    error(err: "Single quote used incorrectly.")
                }
                
            } else if inSingleQuote {
                let lastIndex = newArguments.endIndex - 1
                
                newWord = "\(newArguments[lastIndex]) \(newWord)"
                newArguments.removeLast()
                
            }
            newArguments.append(newWord)
            
        }
        
        if totalQuotes % 2 != 0 {
            error(err: "Single quote used incorrectly. Uneven number of quotes")
        }
        
        task = newArguments
        let newCommandView = CommandView()
        
        if isVerb(str: task.first!) {
            if let count = task.count as Int? {
                let lastindex = count - 1
                let secondlastindex = count - 2

                if count >= 2 {
                    if task[secondlastindex] == "--icon"
                    {
                        let buttonIconPath = validateAndReturnIconPath(filePath: task[lastindex] as NSString)
                        
                        newCommandView.newIconPath = buttonIconPath
                        newCommandView.newIcon = true
                        
                        task.remove(at: lastindex)
                        task.remove(at: secondlastindex)
                        
                    }
                    
                }
                    
            }
            
            if task.first == "wait" {
                task = ["sleep", "0"]
                newCommandView.wait = true
            }
            
        } else {
            let fileManager = FileManager()
            let fileExists = fileManager.fileExists(atPath: task.first!)
            if !fileExists {
                error(err: "\(task.first!) does not exist.")
            }
           
        }
        
        newCommandView.jssCommand = task
        newCommandView.taskName = taskName
        newCommandView.isFile = isFile
        
        if isFile {
            newCommandView.htmlString = nil
        } else {
            newCommandView.localFile = (nil, nil)
        }
        return newCommandView
    }
    
    func error(err:String) {
        print("There is an error in your syntax.")
        print("Error: \(err)")
        print("Use --help for more information.")

        NSApplication.shared.terminate(self)
    }
    
    func validateAndReturnLocalWebFile(filePath:NSString) -> LocalWebFile {
        var file:LocalWebFile = (nil, nil)
        
        let fileManager = FileManager()
        let fileExists = fileManager.fileExists(atPath: filePath as String)
        if fileExists {
            let ext = filePath.pathExtension
            if ext != "html" {
                error(err: "file is not a html file.")
            } else {
                
                let filename = filePath.lastPathComponent
                let range = filePath.range(of: filename)
                
                file.0 = filePath as String //Fullpath
                file.1 = filePath.substring(to: range.location) //Directory
                
                if file.1?.count == 0 {
                    let cwd = FileManager.default.currentDirectoryPath
                    file.1 = "\(cwd)/"
                    file.0 = file.1!.appending(file.0!)
                }
            }
            
        } else {
            error(err: "the html file you have specified does not exist: \(filePath)")
        }
        return file
    }
    
    func validateAndReturnIconPath(filePath: NSString) -> String {
        let fileManager = FileManager()
        let fileExists = fileManager.fileExists(atPath: filePath as String)
        if fileExists {
            let ext = filePath.pathExtension
            if ext != "png" {
                error(err: "icon file must be of type png.")
            } else {
                return filePath as String
            }
        } else {
            error(err: "the icon file you have specified does not exist: \(filePath)")
        }
        return filePath as String
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

}

