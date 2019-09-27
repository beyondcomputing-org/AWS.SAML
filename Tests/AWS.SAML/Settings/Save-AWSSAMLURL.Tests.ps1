Import-Module '.\AWS.SAML.Settings.psm1' -Force

Describe 'Save-AWSSAMLURL' {
    $dir = 'TestDrive:\aws.saml'
    $path = "$dir\Settings.xml"
    $url = 'https://www.amazon.com'
    
    Mock Get-SaveDir -ModuleName AWS.SAML.Settings { 
        return 'TestDrive:\aws.saml'
    }
    
    Mock Read-Host -ModuleName AWS.SAML.Settings { 
        return 'https://www.amazon.com'
    }

    Context 'Saves out the URL' {
        Save-AWSSAMLURL

        It 'Creates a directory' {
            Test-Path $dir | Should Be $true
        }

        It 'Creates a file' {
            Test-Path $path | Should Be $true
        }

        It 'Puts the URL in the file' {
            Import-CliXml -Path $path | Should Be $url
        }
    }
}