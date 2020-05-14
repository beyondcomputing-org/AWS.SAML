using module .\AWS.SAML.Settings.psm1
using module .\AWS.SAML.Utils.psm1

function ConvertFrom-AWSCredential{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Array]$Content,
        [Switch]$LineMarkers
    )

    $profiles = @()

    # Process each line and build credential object
    for ($i = 0; $i -lt $Content.Count; $i++) {
        $line = $Content[$i]
        switch -regex ($line) {
            '^[\t ]*\[.+\][\t ]*$' {
                $name = $line.Trim('[] ')
                Write-Verbose "Found Profile: $name"

                # Create Object
                $_profile = [ordered]@{
                    Name = $name
                    AccessKeyId = ''
                    SecretAccessKey = ''
                    SessionToken = ''
                    AccountID = ''
                    Role = ''
                    Duration = 3600
                }

                # Add Line markers to objects
                if($LineMarkers){
                    # New Profile found - set end marker for previous
                    if($profiles){
                        $profiles[-1].LineEnd = $i -1
                    }

                    $_profile += [ordered]@{
                        LineStart = $i
                        LineEnd = $i
                    }
                }

                $profiles += [pscustomobject]$_profile
                break
            }
            '^[\t ]*aws_access_key_id[\t ]*=' {
                $aki = $line.Replace('aws_access_key_id', '').TrimStart(' =').TrimEnd()
                Write-Verbose "Found Access Key ID: $aki"
                $profiles[-1].AccessKeyId = $aki
                break
            }
            '^[\t ]*aws_secret_access_key[\t ]*=' {
                $sak = $line.Replace('aws_secret_access_key', '').TrimStart(' =').TrimEnd()
                Write-Verbose "Found Secret Access Key: $sak"
                $profiles[-1].SecretAccessKey = $sak
                break
            }
            '^[\t ]*aws_session_token[\t ]*=' {
                $st = $line.Replace('aws_session_token', '').TrimStart(' =').TrimEnd()
                Write-Verbose "Found Session Token: $st"
                $profiles[-1].SessionToken = $st
                break
            }
            '^[\t ]*aws_saml_accountid[\t ]*=' {
                $ai = $line.Replace('aws_saml_accountid', '').TrimStart(' =').TrimEnd()
                Write-Verbose "Found AccountID: $ai"
                $profiles[-1].AccountID = $ai
                break
            }
            '^[\t ]*aws_saml_role[\t ]*=' {
                $r = $line.Replace('aws_saml_role', '').TrimStart(' =').TrimEnd()
                Write-Verbose "Found Role: $r"
                $profiles[-1].Role = $r
                break
            }
            '^[\t ]*aws_saml_duration[\t ]*=' {
                $r = $line.Replace('aws_saml_duration', '').TrimStart(' =').TrimEnd()
                Write-Verbose "Found Duration: $r"
                $profiles[-1].Duration = $r
                break
            }
        }
    }

    # Finished profiles - set marker for last
    if($LineMarkers -and $profiles){
        $profiles[-1].LineEnd = $Content.count - 1
    }

    return $profiles
}

function Get-AWSProfile{
    [CmdletBinding()]
    param(
        [Alias('Profile')]
        [String]$ProfileName
    )

    $file = Get-AWSCredentialFile
    if($file){
        $profiles = ConvertFrom-AWSCredential -Content $file

        if($ProfileName){
            return ($profiles | Where-Object {$_.Name -eq $ProfileName})
        }else{
            return $profiles
        }
    }else{
        Write-Verbose 'No Profiles Found'
        return $null
    }
}

function Update-AWSProfile{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ProfileName,
        [Parameter(Mandatory=$true)]
        [String]$AccessKeyId,
        [Parameter(Mandatory=$true)]
        [String]$SecretAccessKey,
        [Parameter(Mandatory=$true)]
        [String]$SessionToken,
        [Parameter(Mandatory=$true)]
        [String]$AccountID,
        [Parameter(Mandatory=$true)]
        [String]$Role,
        [Parameter(Mandatory=$true)]
        [Int]$SessionDuration
    )

    $file = Get-AWSCredentialFile

    if(!($file)){
        Throw 'No Profiles available to Update'
    }

    $_profile = ConvertFrom-AWSCredential -Content $file -LineMarkers | Where-Object {$_.Name -eq $ProfileName}

    if(!($_profile)){
        Throw "Profile: $ProfileName not found"
    }

    # Split lines on profile
    if($_profile.LineStart -gt 0){
        $before = $file[0..($_profile.LineStart -1)]
    }

    $content = $file[$_profile.LineStart..$_profile.LineEnd]

    if($_profile.LineEnd -lt $file.GetUpperBound(0)){
        $after = $file[($_profile.LineEnd + 1)..$file.GetUpperBound(0)]
    }

    # Remove whitespace
    $content = $content | Where-Object {$_ -ne ''}

    # Update Name - remove whitespace or other characters
    $content[0] = "[$ProfileName]"

    # Update Access Key ID
    $content = Push-StringArrayValue -Array $content -Match '^[\t ]*aws_access_key_id[\t ]*=' -Value "aws_access_key_id = $AccessKeyId"

    # Update Secret Access Key
    $content = Push-StringArrayValue -Array $content -Match '^[\t ]*aws_secret_access_key[\t ]*=' -Value "aws_secret_access_key = $SecretAccessKey"

    # Update Session Token
    $content = Push-StringArrayValue -Array $content -Match '^[\t ]*aws_session_token[\t ]*=' -Value "aws_session_token = $SessionToken"

    # Update Account ID
    $content = Push-StringArrayValue -Array $content -Match '^[\t ]*aws_saml_accountid[\t ]*=' -Value "aws_saml_accountid = $AccountID"

    # Update Role
    $content = Push-StringArrayValue -Array $content -Match '^[\t ]*aws_saml_role[\t ]*=' -Value "aws_saml_role = $Role"

    # Update Session Duration
    $content = Push-StringArrayValue -Array $content -Match '^[\t ]*aws_saml_duration[\t ]*=' -Value "aws_saml_duration = $SessionDuration"

    # Add blank line
    $content += ''

    # Save Changes
    if ($pscmdlet.ShouldProcess('AWS Credential File', "Update Profile: $ProfileName"))
    {
        Save-AWSCredentialFile -FileContent ($before + $content + $after)
    }
}

function New-AWSProfile{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ProfileName,
        [Parameter(Mandatory=$true)]
        [String]$AccessKeyId,
        [Parameter(Mandatory=$true)]
        [String]$SecretAccessKey,
        [Parameter(Mandatory=$true)]
        [String]$SessionToken,
        [Parameter(Mandatory=$true)]
        [String]$AccountID,
        [Parameter(Mandatory=$true)]
        [String]$Role,
        [Parameter(Mandatory=$true)]
        [Int]$SessionDuration
    )

    # Must set return type as array to handle null values
    [Array]$file = Get-AWSCredentialFile

    # Add blank line if needed
    if($file -and $file[-1] -ne ''){
        $file += ''
    }

    $file += "[$ProfileName]"
    $file += "aws_access_key_id = $AccessKeyId"
    $file += "aws_secret_access_key = $SecretAccessKey"
    $file += "aws_session_token = $SessionToken"
    $file += "aws_saml_accountid = $AccountID"
    $file += "aws_saml_role = $Role"
    $file += "aws_saml_duration = $SessionDuration"

    # Save Changes
    if ($pscmdlet.ShouldProcess('AWS Credential File', "Add Profile: $ProfileName"))
    {
        Save-AWSCredentialFile -FileContent $file
    }
}

function Set-AWSProfile{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$true)]
        [Alias('Profile')]
        [String]$ProfileName,
        [Parameter(Mandatory=$true)]
        [String]$AccessKeyId,
        [Parameter(Mandatory=$true)]
        [String]$SecretAccessKey,
        [Parameter(Mandatory=$true)]
        [String]$SessionToken,
        [Parameter(Mandatory=$true)]
        [String]$AccountID,
        [Parameter(Mandatory=$true)]
        [String]$Role,
        [Parameter(Mandatory=$true)]
        [Int]$SessionDuration
    )

    if(Get-AWSProfile -ProfileName $ProfileName){
        Update-AWSProfile -Profile $ProfileName -AccessKeyId $AccessKeyId -SecretAccessKey $SecretAccessKey -SessionToken $SessionToken -AccountID $AccountID -Role $Role -SessionDuration $SessionDuration
    }else{
        New-AwsProfile -Profile $ProfileName -AccessKeyId $AccessKeyId -SecretAccessKey $SecretAccessKey -SessionToken $SessionToken -AccountID $AccountID -Role $Role -SessionDuration $SessionDuration
    }
}