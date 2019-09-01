Import-Module '.\AWS.SAML.psm1' -Force

Describe 'Save-AWSSAMLURL' {
    $dir = 'TestDrive:\aws.saml'
    $path = "$dir\settings.xml"
    $url = 'https://www.amazon.com'
    
    Mock Read-Host -ModuleName AWS.SAML { 
        return 'https://www.amazon.com'
    }

    Context 'Saves out the URL' {
        Save-AWSSAMLURL -SaveDir $dir -SavePath $path

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