# AWS.SAML
See module manifest `AWS.SAML.psd1` for more information.

## Build Status
|Windows|Linux|macOS|
|---|---|---|
|[![Build Status](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_apis/build/status/beyondcomputing-org.AWS.SAML?branchName=master&jobName=Build_PS_Win2016)](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_build/latest?definitionId=7&branchName=master)|[![Build Status](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_apis/build/status/beyondcomputing-org.AWS.SAML?branchName=master&jobName=Build_PSCore_Ubuntu1604)](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_build/latest?definitionId=7&branchName=master)|[![Build Status](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_apis/build/status/beyondcomputing-org.AWS.SAML?branchName=master&jobName=Build_PSCore_MacOS1013)](https://beyondcomputing.visualstudio.com/PowerShell%20Modules/_build/latest?definitionId=7&branchName=master)|

## Using The Module
### How To Login
Invoke Login-AWSSAML to login.  On the first run you will be prompted for the SSO Initiation URL.  The Initiation URL is saved in a file in your profile for subsequent uses.

### SSO Initiation URL
The Initiation URL is the URL that you would login to start the SSO process.  This is the URL provided by your IT team or the first URL that your SSO App Launcher takes you to.

#### Google SSO Initiation URL
Click on the app switcher menu on the top right when logged into a google service.  Scroll down to the AWS option and right click -> "Copy link address".  The address should look similar to the following: `https://accounts.google.com/o/saml2/initsso?idpid=ABC&spid=123&forceauthn=false`.

### CMDLETs
To get more information on each cmdlet run `Get-Help <CMDLET Name>`

#### Authentication CMDLETs
- Login-AWSSAML

### Browsers
The module can support the following Browsers: Chrome, FireFox, Edge and IE.  Chrome is the default as has been tested.  If you are using another browser and have issues, please report them and preferably submit a PR.

### OS
The module can support running on Linux, macOS and Windows.  However, only Windows has been tested currently.  If you are using another OS and have issues, please report them and preferably submit a PR.  

## Changes
See CHANGELOG.md for more information.

## Contributing
See CONTRIBUTING.md for more information.

## License
See LICENSE.md for more information.