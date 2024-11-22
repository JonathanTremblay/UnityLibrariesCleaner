# UNITY LIBRARIES CLEANER

This is a Batch Script to free up disk space by emptying the Library folders of your Unity projects.
(Don't worry, when you open a project, Unity can always rebuild the content of the Library folder.)

## Table of Contents

1. [Getting Started](#getting-started)
2. [Compatibility](#compatibility)
3. [Known Issues](#known-issues)
4. [About the Project](#about-the-project)
5. [Contact](#contact)
6. [Version History](#version-history)
7. [License](#license)
8. [Legal](#legal)

## Getting Started

 Usage and warnings:
 * The .bat file must be placed in a folder containing one or more Unity projects (make sure you have write access for this folder).
 * Double-click on the UnityLibrariesCleaner.bat script to make it run.
 * If Windows prevents the script from running, click on "More info" and then "Run anyway" (don't take my word for it, take a look at the code first!)
 * The script finds all valid Library folders and then offers Manual or Automatic mode.
 * Then the contents of the folders are permanently deleted (not placed in the recycle bin).
 * The "Library/LastSceneManagerSetup.txt" and "Library/EditorUserBuildSettings.asset" files are preserved (these files are keeping the last opened scene of projects and their BuildSettings). 
 * The script cannot process paths if they contain exclamation marks (these paths will be ignored).
 
 That's it!

## Compatibility

* Tested on Windows.

## Known Issues

* The script cannot delete a directory with a path length of more than 256 characters, due to a system limitation. An error message is displayed at the end of the process. To work around this problem, you must shorten the listed project paths before running the script again. (Note that some of Unity features also generate errors when paths are too long, so it's best to always keep your projects in short paths.)
* If the script has a lot of folders to examine, the process may take a long time.

## About the Project

* I created this tool to free up some space on my drives, I hope it helps you to claim back your space too!

## Contact

**Jonathan Tremblay**  
Teacher, Cegep de Saint-Jerome  
jtrembla@cstj.qc.ca

Project Repository: https://github.com/JonathanTremblay/UnityLibrariesCleaner 

## Version History

* 1.0.3
    * Added total folder path length validation to prevent processing errors.
    * Added folder numbering to make the script easier to use.
    * Added a note about exclamation marks in paths.
* 1.0.2
    * Added folder path length detection to prevent errors.
    * Changed color codes for feedback.
    * Improved search speed again.
* 1.0.1
    * Improved search speed (1.0.0 attempt was not working).
* 1.0.0
    * Improved search speed. BuildSettings preservation.
* 0.9.9
    * Fixed manual mode when path contains spaces.
* 0.9.8
    * First public version.

## License

This script is available for distribution and modification under the CC0 License, which allows for free use and modification.  
https://creativecommons.org/share-your-work/public-domain/cc0/

## Legal

By using this script, you acknowledge and agree that:

1. You are solely responsible for the usage and consequences of running this script.
2. The author of the script and the contributors to the project are not responsible for any damages, loss of data, or other issues caused by the usage of this script.
3. It is your responsibility to review and understand the script code before running it to ensure it meets your requirements and does not pose any security risks.
4. Use this script at your own risk.