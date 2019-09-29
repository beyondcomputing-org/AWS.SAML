Import-Module '.\AWS.SAML.Profile.psm1' -Force

Describe 'Get-AWSProfile' {
    $answers = @(
        [PSCustomObject]@{
            Name = 'Dev'
            AccessKeyId = '123'
            SecretAccessKey = 'abc'
            SessionToken = '111'
        },
        [PSCustomObject]@{
            Name = 'Test'
            AccessKeyId = 'acb1d27b-de8c-48ee-98bd-0c74dda7f05'
            SecretAccessKey = '2b6fcc36-e80e-4968-82f8-b88d088741cd'
            SessionToken = '5a477223-058a-4597-ab73-0a9100efb0755a477223-058a-4597-ab73-0a9100efb0755a477223-058a-4597-ab73-0a9100efb0755a477223-058a-4597-ab73-0a9100efb0755a477223-058a-4597-ab73-0a9100efb075=='
        }
    )

    Mock Get-AWSCredentialFile -ModuleName AWS.SAML.Profile { 
        return 'data'
    }

    Mock ConvertFrom-AWSCredential -ModuleName AWS.SAML.Profile { 
        return $answers
    }.GetNewClosure()

    foreach ($answer in $answers) {
        Context "Gets $($answer.Name) Profile" {
            It 'Without modifying' {
                $response = Get-AWSProfile | Where-Object {$_.Name -eq $answer.Name}
    
                $response.Name | Should Be $answer.Name
                $response.AccessKeyId | Should Be $answer.AccessKeyId
                $response.SecretAccessKey | Should Be $answer.SecretAccessKey
                $response.SessionToken | Should Be $answer.SessionToken
            }

            It 'Calls Get-AWSCredentailsFile once' {
                Assert-MockCalled Get-AWSCredentialFile -ModuleName AWS.SAML.Profile -Exactly -Times 1
            }

            It 'Calls ConvertFrom-AWSCredential once' {
                Assert-MockCalled Get-AWSCredentialFile -ModuleName AWS.SAML.Profile -Exactly -Times 1
            }
        }
    }

    foreach ($answer in $answers) {
        Context "Gets only $($answer.Name) Profile with filter" {
            It 'Without modifying' {
                $response = Get-AWSProfile -ProfileName $answer.Name
    
                $response.Name | Should Be $answer.Name
                $response.AccessKeyId | Should Be $answer.AccessKeyId
                $response.SecretAccessKey | Should Be $answer.SecretAccessKey
                $response.SessionToken | Should Be $answer.SessionToken
            }

            It 'Calls Get-AWSCredentailsFile once' {
                Assert-MockCalled Get-AWSCredentialFile -ModuleName AWS.SAML.Profile -Exactly -Times 1
            }

            It 'Calls ConvertFrom-AWSCredential once' {
                Assert-MockCalled Get-AWSCredentialFile -ModuleName AWS.SAML.Profile -Exactly -Times 1
            }
        }
    }

    Context 'Empty file' {
        Mock ConvertFrom-AWSCredential -ModuleName AWS.SAML.Profile { 
            return $null
        }

        $response = Get-AWSProfile

        It 'Returns no profiles' {
            $response | Should Be $null
        }
    }
}