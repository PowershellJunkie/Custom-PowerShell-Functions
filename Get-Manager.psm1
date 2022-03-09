<#
A simple function designed to get no only the user's manager, but to do so in an easily readable format and output information specific to that manager. 
This will specifically get the manager's Display Name, sAMAccountName, User Principal Name (which should match their email address) and whether or not that manager's account is enabled in Active Directory.
#>

Function Get-Manager{

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
            )]

            [string] $Identity
                        
            )


    Begin{}

    Process{
        $UserAccount = Get-ADUser $Identity -Properties manager,DisplayName
        $UserAccount | Select -ExpandProperty manager | ForEach-Object {
        $Manager = Get-ADUser $_ -Properties DirectReports,DisplayName,UserPrincipalName,sAMAccountName,Enabled
        if ($null -ne $Manager.sAMAccountName){

            [PSCustomObject]@{
                sAMAccountName = $Manager.sAMAccountName
                UserPrincipalName = $Manager.UserPrincipalName
                DisplayName = $Manager.DisplayName
                Manager = $Manager.DisplayName
                ManagerEnabled = $Manager.Enabled
                }
             }
        }
    }

}

End {}
