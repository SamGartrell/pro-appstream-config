# Appstream Pro Config

This repository contains a collection of batch files that can be used to configure user-specific in arcgis pro. The process is designed to be triggered by the `trigger-pro-config.bat` process, running as an Appstream Session Script. 
### Execution steps:
- User connects to app stream, a GIS workspace image is instantiated
- Appstream session script configuration launches the `trigger-pro-config.bat` file
- `trigger-pro-config.bat` monitors the the storage connector's mounting process (i.e. HomeFolder) by checking its [status in the registry](https://docs.aws.amazon.com/appstream2/latest/developerguide/use-session-scripts.html#use-storage-connectors-with-session-scripts)
- calls `pro-config.bat` when ready
- `pro-config.bat` calls a shortcut to itself that has administrative access
- with elevated access and user context established, `pro-config.bat` can then 
  - create a default storage location for arcgis pro in the user's HomeFolder or other storage connector
  - create a `Pro.settingsConfig` file pointing at the storage location
  - add that file to the windows registry
- finally, arcgis pro launches and reads its settings from the `Pro.settingsConfig` file

### Implementation
the contents of this repo should be copied to the AppStreamScripts folder on ImageBuilder Admin's machine as follows:
```
C:\
├───AppStream                               this dir is part of the default appstream configuration
│   └───SessionScripts
│           config.json                    
│
├───AppStreamScripts
│   └───apply-settings                      files in this dir get invoked by the config.json
│   │       arcpro-config.bat
│   │       arcpro-config.bat-asadmin.lnk
│   │       trigger-arcpro-config.bat
│   └───logging                             Process logging gets written to an S3 bucket too
│   │       pro-config.log
│   │       storage-mount.log
│   └───pro-config                          Pro.settingsConfig gets made in/read from here
│           ProSettings.xsd
```
