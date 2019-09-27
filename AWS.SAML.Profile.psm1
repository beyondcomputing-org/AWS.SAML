using module .\AWS.SAML.Settings.psm1

function Get-AWSProfile{
    [CmdletBinding()]
    param(
        [Alias('Profile')]
        [String]$ProfileName
    )

    $directory = Get-AWSDirectory
    $file = Get-Content -Path "$directory`credentials"

    $profiles = @()

    # Process each line and build credential object
    foreach ($line in $file) {
        switch -regex ($line) {
            '^\[.+\]$' {
                $name = $line.Trim('[]')
                Write-Verbose "Found Profile: $name"

                $profile = [pscustomobject][ordered]@{
                    Name = $name
                    AccessKeyId = ''
                    SecretAccessKey = ''
                    SessionToken = ''
                }
                $profiles += $profile
                break
            }
            '^aws_access_key_id' {
                $aki = $line.Replace('aws_access_key_id = ', '')
                Write-Verbose "Found Access Key ID: $aki"
                $profiles[-1].AccessKeyId = $aki
                break
            }
            '^aws_secret_access_key = ' {
                $sak = $line.Replace('aws_secret_access_key =', '')
                Write-Verbose "Found Secret Access Key: $sak"
                $profiles[-1].SecretAccessKey = $sak
                break
            }
            '^aws_session_token = ' {
                $st = $line.Replace('aws_session_token =', '')
                Write-Verbose "Found Session Token: $st"
                $profiles[-1].SessionToken = $st
                break
            }
        }
    }

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

    $directory = Get-AWSDirectory
    $file = Get-Content -Path "$directory`credentials"

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