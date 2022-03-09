<#
Purpose is to allow the user of this function to search for specific Active Directory users and get the direct reports of the searched user. 
The default action of this function as it stands is to recursively search the direct reports of the searched manager. 
The 'NoRecurse' switch exists to prevent this when it is desirable to do so.
 #>
 
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
