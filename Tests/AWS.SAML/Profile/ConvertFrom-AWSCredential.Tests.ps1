Import-Module '.\AWS.SAML.Profile.psm1' -Force

Describe 'ConvertFrom-AWSCredential' {
    $answers = @(
        [PSCustomObject]@{
            Name = 'Dev'
            AccessKeyId = '123'
            SecretAccessKey = 'abc'
            SessionToken = '111'
            LineStart = 0
            LineEnd = 4
            TestCases = @(
                @{File = 'normal'},@{File = 'extra'},@{File = 'spacing'},@{File = 'missing'}
            )
        },
        [PSCustomObject]@{
            Name = 'Test'
            AccessKeyId = 'acb1d27b-de8c-48ee-98bd-0c74dda7f05'
            SecretAccessKey = '2b6fcc36-e80e-4968-82f8-b88d088741cd'
            SessionToken = '5a477223-058a-4597-ab73-0a9100efb0755a477223-058a-4597-ab73-0a9100efb0755a477223-058a-4597-ab73-0a9100efb0755a477223-058a-4597-ab73-0a9100efb0755a477223-058a-4597-ab73-0a9100efb075=='
            LineStart = 5
            LineEnd = 10
            TestCases = @(
                @{File = 'normal'},@{File = 'extra'},@{File = 'spacing'}
            )
        },
        [PSCustomObject]@{
            Name = 'Test'
            AccessKeyId = 'acb1d27b-de8c-48ee-98bd-0c74dda7f05'
            SecretAccessKey = ''
            SessionToken = ''
            LineStart = 5
            LineEnd = 10
            TestCases = @(
               @{File = 'missing'}
            )
        },
        [PSCustomObject]@{
            Name = 'Prod'
            AccessKeyId = '456'
            SecretAccessKey = 'def'
            SessionToken = '222'
            LineStart = 11
            LineEnd = 14
            TestCases = @(
                @{File = 'normal'},@{File = 'extra'},@{File = 'spacing'},@{File = 'missing'}
            )
        }
    )

    foreach ($answer in $answers) {
        Context "Gets $($answer.Name) Profile" {
            It 'From File <File>' -TestCases $answer.TestCases {
                param($File)
    
                $content = Get-Content -Path ".\Tests\AWS.SAML\Profile\CredentialFiles\Source\$File"
                $response = ConvertFrom-AWSCredential -Content $content | Where-Object {$_.Name -eq $answer.Name}
    
                $response.Name | Should Be $answer.Name
                $response.AccessKeyId | Should Be $answer.AccessKeyId
                $response.SecretAccessKey | Should Be $answer.SecretAccessKey
                $response.SessionToken | Should Be $answer.SessionToken
            }
        }
    }

    foreach ($answer in $answers) {
        Context "Gets $($answer.Name) Profile with line markers" {
            It 'From File <File>' -TestCases $answer.TestCases {
                param($File)
    
                $content = Get-Content -Path ".\Tests\AWS.SAML\Profile\CredentialFiles\Source\$File"
                $response = ConvertFrom-AWSCredential -Content $content -LineMarkers | Where-Object {$_.Name -eq $answer.Name}
    
                $response.Name | Should Be $answer.Name
                $response.AccessKeyId | Should Be $answer.AccessKeyId
                $response.SecretAccessKey | Should Be $answer.SecretAccessKey
                $response.SessionToken | Should Be $answer.SessionToken
                $response.LineStart | Should Be $answer.LineStart
                $response.LineEnd | Should Be $answer.LineEnd
            }
        }
    }

    Context 'Empty file' {
        $response = ConvertFrom-AWSCredential -Content ''

        It 'Returns no profiles' {
            $response | Should Be $null
        }
    }
}