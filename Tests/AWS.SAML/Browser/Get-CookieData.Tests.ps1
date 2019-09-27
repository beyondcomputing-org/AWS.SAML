Import-Module '.\AWS.SAML.Browser.psm1' -Force

Describe 'Get-CookieData' {

    $Cookies = Get-Content "$PSScriptRoot\cookies.json" | ConvertFrom-Json
    
    Context 'Parses cookie data' {
        $Data = Get-CookieData -Cookies $Cookies

        It 'Gets correct AccountID' {
            $Data.AccountID | Should Be '123456789'
        }

        It 'Gets correct Alias' {
            $Data.Alias | Should Be 'account-1'
        }

        It 'Gets correct Role' {
            $Data.Role | Should Be 'User'
        }

        It 'Gets correct Name' {
            $Data.Name | Should Be 'john.doe@aws.com'
        }
    }
}