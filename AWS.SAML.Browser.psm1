using module .\AWS.SAML.Settings.psm1
using module .\AWS.SAML.ChromeDriver.psm1

function Get-ConsoleData{
    [CmdletBinding()]
    param(
        $Driver,
        $Timeout = 60000
    )
    # Wait for user to complete login process
    do {
        Write-Progress 'Please select the role that you would like to use and login to the console.' -SecondsRemaining ($Timeout/1000)
        if($Timeout -gt 0){
            Start-Sleep -Milliseconds 100
            $Timeout -= 100
        }else{
            Throw "Exceeded timeout of $Timeout ms waiting for user to select role and login"
        }
    } until ($Driver.Title -eq 'AWS Management Console')

    # Getting Data from Cookies
    Write-Progress 'Detected Console Login!  Getting details and closing browser.'
    $cookies = $Driver.Manage().Cookies.AllCookies

    Return Get-CookieData -Cookies $cookies
}

function Get-CookieData{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
        $Cookies
    )
    $userInfo = $Cookies | Where-Object Name -eq 'aws-userInfo'
    $info = [System.Web.HttpUtility]::UrlDecode($userInfo.Value) | ConvertFrom-Json

    return [ordered]@{
        AccountID = ($info.arn -split ':')[4]
        Alias = $info.alias
        Role = (($info.arn -split ':')[5] -split '/')[1]
        Name = ($info.arn -split '/')[-1]
    }
}

function Get-SAMLAssertion {
    [CmdletBinding()]
    param(
        $Driver,
        $Timeout = 60000
    )

    # Wait for SAML Form
    do {
        Write-Progress 'Please login to the console.  Once you login we will pull the SAML Assertion.' -SecondsRemaining ($Timeout/1000)
        if($Timeout -gt 0){
            Start-Sleep -Milliseconds 100
            $Timeout -= 100
        }else{
            Throw "Exceeded timeout of $Timeout ms waiting for browser to load AWS SAML page"
        }
    } until ($Driver.url -eq 'https://signin.aws.amazon.com/saml')

    Write-Progress 'Extracting SAML Assertion'
    $Element = Get-SeElement -name 'SAMLResponse' -Driver $Driver
    return Get-SeElementAttribute -Element $Element -Attribute 'Value'
}

function Start-Browser {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [String]$InitURL,
        [ValidateSet('Chrome', 'Firefox', 'Edge', 'IE')]
        [String]$Browser,
        [Switch]$NoProfile,
        [Switch]$Headless
    )

    if ($pscmdlet.ShouldProcess($Browser, 'start'))
    {
        # Open Browser and launch login page
        switch ($Browser) {
            'Firefox' {
                Write-Warning 'FireFox functionality has not been tested!'
                $Driver = Start-SeFirefox -StartURL $InitURL
            }
            'Edge' {
                Write-Warning 'Edge functionality has not been tested!'
                $Driver = Start-SeEdge -StartURL $InitURL
            }
            'IE' {
                Write-Warning 'IE functionality has not been tested!'
                $Driver = Start-SeInternetExplorer -StartURL $InitURL
            }
            Default {
                $Arguments = @{
                    Arguments = @("--app=$InitURL")
                }

                # Manage Chrome Driver Version
                try{
                    $driverPath = Get-ChromeDriverNeeded
                    $driverDirectory = Split-Path $driverPath -Parent
                    $Arguments += @{
                        WebDriverDirectory = $driverDirectory
                    }
                }catch{
                    Write-Warning "Error: $_"
                    Write-Warning 'Failed to auto update chrome driver.  Using default driver instead.'
                }

                # Add Profile
                if(!($NoProfile)){
                    $Arguments += @{
                        ProfileDirectoryPath = "$(Get-SaveDir)\Chrome"
                    }
                }

                if($Headless){
                    # TODO: Headless chrome isn't working with the profile path.  Need to address or load in cookies for Auth.
                    # the -Headless flag is currently not enabled on Start-SeChrome

                    # The following closed bugs should allow the functionality we need
                    # https://bugs.chromium.org/p/chromium/issues/detail?id=775703
                    # https://bugs.chromium.org/p/chromium/issues/detail?id=617931
                }

                $Driver = Start-SeChrome @Arguments
            }
        }

        Return $Driver
    }
}