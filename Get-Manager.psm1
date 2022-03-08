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