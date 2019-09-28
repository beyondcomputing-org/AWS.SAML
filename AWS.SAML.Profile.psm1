using module .\AWS.SAML.Settings.psm1

function ConvertFrom-AWSCredential{
    [CmdletBinding()]
    param(
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
                $profile = [ordered]@{
                    Name = $name
                    AccessKeyId = ''
                    SecretAccessKey = ''
                    SessionToken = ''
                }

                # Add Line markers to objects        
                if($LineMarkers){
                    # New Profile found - set end marker for previous
                    if($profiles){
                        $profiles[-1].LineEnd = $i -1
                    }

                    $profile += [ordered]@{
                        LineStart = $i
                        LineEnd = $i
                    }
                }

                $profiles += [pscustomobject]$profile
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
    $profiles = ConvertFrom-AWSCredential -Content $file

    if($ProfileName){
        return ($profiles | Where-Object {$_.Name -eq $ProfileName})
    }else{
        return $profiles
    }
}

function Update-AWSProfile{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Alias('Profile')]
        [String]$ProfileName,
        [String]$AccessKeyId,
        [String]$SecretAccessKey,
        [String]$SessionToken
    )

    $file = Get-AWSCredentialFile
    $profiles = ConvertFrom-AWSCredential -Content $file

    $currentProfile = $false

    # Find Profile
    for ($i = 0; $i -lt $file.Count; $i++) {
        switch -regex ($file[$i]) {
            '^\[.+\]$' {
                $name = $file[$i].Trim('[]')
                Write-Verbose "Found Profile: $name"

                # Mark currentProfile to block accidental updating of other profiles.
                if($name -eq $ProfileName){
                    $currentProfile = $true
                }else{
                    $currentProfile = $false
                }
                break
            }
            '^aws_access_key_id' {
                if($currentProfile){
                    $file[$i] = "aws_access_key_id = $AccessKeyId"
                }
                break
            }
            '^aws_secret_access_key = ' {
                if($currentProfile){
                    $file[$i] = "aws_secret_access_key = $SecretAccessKey"
                }
                break
            }
            '^aws_session_token = ' {
                if($currentProfile){
                    $file[$i] = "aws_session_token = $SessionToken"
                }
                break
            }
        }
    }

    $file | Set-Content -Path "$directory`credentials"
}

function New-AWSProfile{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Alias('Profile')]
        [String]$ProfileName,
        [String]$AccessKeyId,
        [String]$SecretAccessKey,
        [String]$SessionToken
    )

    $directory = Get-AWSDirectory
    $file = Get-Content -Path "$directory`credentials"

    # Add blank line if needed
    if($file[-1] -ne ''){
        $file += ''
    }

    $file += "[$ProfileName]"
    $file += "aws_access_key_id = $AccessKeyId"
    $file += "aws_secret_access_key = $SecretAccessKey"
    $file += "aws_session_token = $SessionToken"

    $file | Set-Content -Path "$directory`credentials"
}

function Set-AWSProfile{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Alias('Profile')]
        [String]$ProfileName,
        [String]$AccessKeyId,
        [String]$SecretAccessKey,
        [String]$SessionToken
    )

    if(Get-AWSProfile -ProfileName $ProfileName){
        Update-AWSProfile -Profile $ProfileName -AccessKeyId $AccessKeyId -SecretAccessKey $SecretAccessKey -SessionToken $SessionToken
    }else{
        New-AwsProfile -Profile $ProfileName -AccessKeyId $AccessKeyId -SecretAccessKey $SecretAccessKey -SessionToken $SessionToken
    }
}