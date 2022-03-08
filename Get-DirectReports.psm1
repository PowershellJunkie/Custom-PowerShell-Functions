Function Get-DirectReports{

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
            )]

            [string] $Identity,
            [switch] $NoRecurse
            )


    Begin{}

    Process{
        $UserAccount = Get-ADUser $Identity -Properties DirectReports,DisplayName
        $UserAccount | Select -ExpandProperty DirectReports | ForEach-Object {
        $User = Get-ADUser $_ -Properties DirectReports,DisplayName,UserPrincipalName,sAMAccountName | Where {$_.Enabled -eq $true}
        if ($null -ne $User.sAMAccountName){
            if(-not $NoRecurse){
                Get-DirectReports $User.sAMAccountName
                }
            [PSCustomObject]@{
                sAMAccountName = $User.sAMAccountName
                UserPrincipalName = $User.UserPrincipalName
                DisplayName = $User.DisplayName
                Manager = $UserAccount.DisplayName
                }
             }
        }
    }

}

End {}