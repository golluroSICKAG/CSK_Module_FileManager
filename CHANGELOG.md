# Changelog
All notable changes to this project will be documented in this file.

## Release 1.1.1

### Bugfix
- Legacy bindings of ValueDisplay / upload button / download button elements within UI did not work if deployed with VS Code AppSpace SDK
- UI differs if deployed via Appstudio or VS Code AppSpace SDK
- Fullscreen icon of iFrame was visible

## Release 1.1.0

### New features
- Provide version of module via 'OnNewStatusModuleVersion'
- Serves 'updateListOfFiles' to trigger via UI
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function

### Improvements
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- 'loadParameters' returns its success
- 'sendParameters' prepared to control if sent data should be saved directly by CSK_Module_PersistentData (but not used as there are no parameters available so far)
- Added UI icon and browser tab information
- Removed useless functions regarding PersistentData

### Bugfix
- 'Disk usage' in UI showed free bytes and not used bytes

## Release 1.0.0

### New features
- Prepared for PersistentData features (not used so far and removed in version 1.1.0)

### Improvements
- Requires userlevel "Service" to provide UI

### Bugfix
- Download of first preselected file did not work after app reboot

## Release 0.1.0
- Initial commit