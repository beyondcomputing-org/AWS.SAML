Import-Module '.\AWS.SAML.Settings.psm1' -Force

Describe 'Get-AWSCredentialFile' {
    $dir = 'TestDrive:\.aws\'
    
    Mock Get-AWSDirectory -ModuleName AWS.SAML.Settings { 
        return $dir
    }.GetNewClosure()

    Context 'Folder is missing' {
        $response = Get-AWSCredentialFile

        It 'Calls Get-AWSDirectory once' {
            Assert-MockCalled Get-AWSDirectory -ModuleName AWS.SAML.Settings -Exactly -Times 1
        }

        It 'Returns empty string' {
            $response | Should Be ''
        }
    }

    Context 'File is missing' {
        New-Item -ItemType Directory $dir
        $response = Get-AWSCredentialFile

        It 'Calls Get-AWSDirectory once' {
            Assert-MockCalled Get-AWSDirectory -ModuleName AWS.SAML.Settings -Exactly -Times 1
        }

        It 'Returns empty string' {
            $response | Should Be ''
        }
    }

    Context 'File present' {
        $content = @('abc','123')
        
        # Create File
        New-Item -ItemType Directory $dir
        New-Item -ItemType File "$dir`credentials"
        $content | Set-Content "$dir`credentials"

        $response = Get-AWSCredentialFile

        It 'Calls Get-AWSDirectory once' {
            Assert-MockCalled Get-AWSDirectory -ModuleName AWS.SAML.Settings -Exactly -Times 1
        }

        It 'Returns file content' {
            $response | Should Be $content
        }
    }
}