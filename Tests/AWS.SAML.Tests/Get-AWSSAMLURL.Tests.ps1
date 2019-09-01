Import-Module '.\AWS.SAML.psm1' -Force

Describe 'Get-AWSSAMLURL' {
    $dir = 'TestDrive:\aws.saml'
    $path = "$dir\settings.xml"
    $url = 'https://www.amazon.com'

    New-Item -Type Directory -Path $dir | Out-Null
    $url | Export-CliXml -Path ($path)  -Encoding 'utf8' -Force

    Context 'Reads out a saved URL' {
        $response = Get-AWSSAMLURL -SavePath $path

        It 'Gets the correct value' {
            $response | Should Be $url
        }
    }
}