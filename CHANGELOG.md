# Changelog

## Deprecated Features
*These will be removed in the next major release*
- N/A

1.3.0
-----
- Added auto update support for chrome drivers on Windows

1.2.0
-----
- Added configurable session duration to the Profile
- Added `Update-AWSSAML` and `uas` as alias for `Update-AWSSAMLLogin`

1.1.0
-----
- Added configurable session duration support

1.0.0
-----
- Bumping Selenium module to version 2.3.1
- Bumping AWS.Tools.SecurityToken to version 4.0.2.0

0.9.0
-----
- Requiring version 6+ of powershell.  All testing is happening on version 6+ and a few issues have been found when using version 5.
- Explicitly setting credential file to UTF-8 NoBOM
- Bumping Selenium module to version 2.1
- Cleanup help files
- Improve test speed by rewriting Script Analyzer Tests

0.8.0
-----
- Added new cmdlet `Update-AWSSAMLLogin`
- Fixed bug when not specifying profile
- Other bug fixes and enhancements

0.7.1
-----
- Added ~100 tests to profile management
- Rewrote profile code to allow for easier testing and address corner cases / bugs

0.7.0
-----
- Added basic profile support

0.6.0
-----
- Fixed Chrome Profile Path for MacOS
- Added alias `las` for Login-AWSSAML
- Split out code base into multiple modules for easier maintenance

0.5.1
-----
- Fixed Chrome Profile Path

0.5.0
-----
- Improved support for macOS

0.4.0
-----
- Updating Selenium dependency to 2.0.0
- Defaulting Chrome to use app mode and profile option to allow credential re-use

0.3.0
-----
- Adding test coverage

0.2.0
-----
- Updated to use new modular AWS Modules
- Restructured code for easier maintenance and testing
- Improved README

0.1.0
-----
- Pre-Release

- - - - -
Check the [Mastering Markdown](https://guides.github.com/features/mastering-markdown/) for basic syntax.
- - - - -
Following [Semantic Versioning](https://semver.org/)
- - - - -
*Major version zero (0.y.z) is for initial development. Anything may change at any time.  Thus a breaking change was introduced in this version.