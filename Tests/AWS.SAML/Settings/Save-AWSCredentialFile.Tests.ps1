Import-Module '.\AWS.SAML.Settings.psm1' -Force

Describe 'Save-AWSCredentialFile' {
    $dir = 'TestDrive:\.aws\'
    $content = @('abc','123')
    
    Mock Get-AWSDirectory -ModuleName AWS.SAML.Settings { 
        return $dir
    }.GetNewClosure()
    

    Context 'Folder is missing' {
        Save-AWSCredentialFile -FileContent $content

        It 'Calls Get-AWSDirectory once' {
            Assert-MockCalled Get-AWSDirectory -ModuleName AWS.SAML.Settings -Exactly -Times 1
        }

        It 'Creates folder' {
            Test-Path $dir | Should Be $true
        }

        It 'Creates credential file' {
            Test-Path "$dir`credentials" | Should Be $true
        }

        It 'Sets credential file contents' {
            Get-Content "$dir`credentials" | Should Be $content
        }
    }

    Context 'File is missing' {
        New-Item -ItemType Directory $dir
        Save-AWSCredentialFile -FileContent $content

        It 'Calls Get-AWSDirectory once' {
            Assert-MockCalled Get-AWSDirectory -ModuleName AWS.SAML.Settings -Exactly -Times 1
        }

        It 'Creates credential file' {
            Test-Path "$dir`credentials" | Should Be $true
        }

        It 'Sets credential file contents' {
            Get-Content "$dir`credentials" | Should Be $content
        }
    }

    Context 'File present' {
        Save-AWSCredentialFile -FileContent $content

        It 'Calls Get-AWSDirectory once' {
            Assert-MockCalled Get-AWSDirectory -ModuleName AWS.SAML.Settings -Exactly -Times 1
        }

        It 'Sets credential file contents' {
            Get-Content "$dir`credentials" | Should Be $content
        }
    }
}