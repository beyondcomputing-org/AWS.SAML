Import-Module '.\AWS.SAML.Settings.psm1' -Force

Describe 'Get-AWSSAMLURL' {
    $dir = 'TestDrive:\aws.saml'
    $path = "$dir\Settings.xml"
    $url = 'https://www.amazon.com'

    Mock Get-SaveDir -ModuleName AWS.SAML.Settings { 
        return 'TestDrive:\aws.saml'
    }

    Mock Save-AWSSAMLURL -ModuleName AWS.SAML.Settings { 
        Throw 'Error - Failed to find item in TestDrive'
    }

    New-Item -Type Directory -Path $dir | Out-Null
    $url | Export-CliXml -Path ($path)  -Encoding 'utf8' -Force

    Context 'Reads out a saved URL' {
        $response = Get-AWSSAMLURL

        It 'Gets the correct value' {
            $response | Should Be $url
        }
    }
}