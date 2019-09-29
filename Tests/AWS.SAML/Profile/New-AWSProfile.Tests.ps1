Import-Module '.\AWS.SAML.Profile.psm1' -Force

Describe 'New-AWSProfile' {
        $testCases = @(
            @{
                SourceFile = 'blank'
                AnswerFile = 'blank'
            },
            @{
                SourceFile = 'normal'
                AnswerFile = 'new'
            }
        )

    Mock Save-AWSCredentialFile -ModuleName AWS.SAML.Profile {
        $FileContent | Set-Content 'TestDrive:\output'
    }

    foreach ($test in $testCases) {
        Mock Get-AWSCredentialFile -ModuleName AWS.SAML.Profile { 
            return Get-Content -Path ".\Tests\AWS.SAML\Profile\CredentialFiles\Source\$($test.SourceFile)"
        }.GetNewClosure()

        Context "New profile in Source File: [$($test.SourceFile)] matches Answer File: [$($test.AnswerFile)]" {
            New-AWSProfile -ProfileName 'New' -AccessKeyId 'ff19-5d55' -SecretAccessKey '4cd2-b6da' -SessionToken '8406-ad68' -AccountID '123' -Role 'user'
            $answer = Get-Content -Path ".\Tests\AWS.SAML\Profile\CredentialFiles\Answer\$($test.AnswerFile)"
            $output = Get-Content -Path 'TestDrive:\output'
            
            It 'Calls Save-AWSCredentialFile Mock' {
                Assert-MockCalled Save-AWSCredentialFile -ModuleName AWS.SAML.Profile -Exactly -Times 1 -Scope Context
            }

            It 'File is same length' {
                $output.Count | Should Be $answer.Count
            }

            for ($i = 0; $i -lt $answer.Count; $i++) {
                It "Line $($i+1) - matches" {
                    $output[$i] | Should Be $answer[$i]
                } 
            }
        }
    }
}