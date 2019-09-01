Import-Module '.\AWS.SAML.psm1' -Force

Describe 'Get-SAMLRole' {

    $samlAssertion = Get-Content "$PSScriptRoot\SAML.assertion"
    
    Context 'Parses SAML assertion' {
        $cases = @{ 
                    accountID = '123'
                    role = 'User' 
                },@{ 
                    accountID = '123'
                    role = 'User2' 
                },@{
                    accountID = '456'
                    role = 'User' 
                },@{ 
                    accountID = '456'
                    role = 'User2'  
                }

        It "Gets correct PrincipalArn for Account:<accountID>, Role:<role>" -TestCases $cases {
            param($accountID, $role)
            $Data = Get-SAMLRole -Assertion $samlAssertion -AccountID $accountID -Role $role
            $Data.PrincipalArn | Should Be 'arn:aws:iam::123456789:saml-provider/GoogleApps'
        }

        It 'Gets correct RoleArn for Account:<accountID>, Role:<role>' -TestCases $cases {
            param($accountID, $role)
            $Data = Get-SAMLRole -Assertion $samlAssertion -AccountID $accountID -Role $role
            $Data.RoleArn | Should Be "arn:aws:iam::$accountID`:role/$role"
        }
    }
}