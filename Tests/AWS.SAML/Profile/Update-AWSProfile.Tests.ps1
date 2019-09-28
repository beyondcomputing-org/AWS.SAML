Import-Module '.\AWS.SAML.Profile.psm1' -Force

Describe 'Update-AWSProfile' {
        $testCases = @(
            @{
                SourceFile = 'normal'
                AnswerFile = 'normal'
            },
            @{
                SourceFile = 'spacing'
                AnswerFile = 'spacing'
            },
            @{
                SourceFile = 'missing'
                AnswerFile = 'normal'
            },
            @{
                SourceFile = 'extra'
                AnswerFile = 'extra'
            }
        )

    Mock Save-AWSCredentialFile -ModuleName AWS.SAML.Profile {
        $FileContent | Set-Content 'TestDrive:\output'
    }

    foreach ($test in $testCases) {
        Mock Get-AWSCredentialFile -ModuleName AWS.SAML.Profile { 
            return Get-Content -Path ".\Tests\AWS.SAML\Profile\CredentialFiles\Source\$($test.SourceFile)"
        }.GetNewClosure()

        Context "Output from Source File: [$($test.SourceFile)] matches Answer File: [$($test.AnswerFile)]" {
            Update-AWSProfile -ProfileName 'Test' -AccessKeyId 'ff19-5d55' -SecretAccessKey '4cd2-b6da' -SessionToken '8406-ad68'
            $answer = Get-Content -Path ".\Tests\AWS.SAML\Profile\CredentialFiles\Answer\$($test.AnswerFile)"
            $output = Get-Content -Path 'TestDrive:\output'
            
            It 'Calls Save-AWSCredentialFile Mock' {
                Assert-MockCalled Save-AWSCredentialFile -ModuleName AWS.SAML.Profile -Exactly -Times 1 -Scope Context
            }

            for ($i = 0; $i -lt $answer.Count; $i++) {
                It "Line $($i+1) - matches" {
                    $output[$i] | Should Be $answer[$i]
                } 
            }
        }
    }
}