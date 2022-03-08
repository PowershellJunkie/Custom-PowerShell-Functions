<#
Original Code written by Ben Sparks (as far as I now), a friend of mine. 

His GitHub can be found here:
https://github.com/sparksbenjamin
#>

function SQL-Query{
param(
[Parameter(Position=0,mandatory=$true)]
[string]$Query,
[Parameter(Position=1,mandatory=$true)]
[string]$Instance,
[string]$Database = 'tempdb',
[string]$UserName,
[string]$PWD

)
$output = New-Object System.Object
Write-Progress -Id 0 -Activity 'Running SQL Query' -Status "Connecting to Server" -CurrentOperation $computer -PercentComplete ( 1/5 * 100)
try{
try{
$SQLServer = $Instance #use Server\Instance for named SQL instances!
$SQLDBName = $Database
$handler=[System.Data.SqlClient.SqlInfoMessageEventHandler] {Write-Verbose "$($_)"}
$output | Add-Member -Type NoteProperty -Name InstanceName -Value $Instance
$output | Add-Member -Type NoteProperty -Name DatabaseName -Value $Database
$output | Add-Member -Type NoteProperty -Name StartTime -Value (Get-Date)
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
#$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName;
if([string]::IsNullOrEmpty($UserName)){$SqlConnection.ConnectionString = "Server=$Instance; Database=$Database;Trusted_Connection=True;"}
else{
$SqlConnection.ConnectionString = "Server = $Instance; Database = $Database; User ID=$UserName; Password=$PWD"
}
$SqlConnection.add_infoMessage($handler)
$SQLConnection.FireInfoMessageEventOnUserErrors = $true
$SQLConnection.Open()
}catch{
$output | Add-Member -Type NoteProperty -Name Error -Value "Unable to open connection to SQL Server"
throw
}
try{
#Write-Progress -Id 0 -Activity 'Running SQL Query' -Status "Connecting to Server" -CurrentOperation $computer -PercentComplete ( 2/5 * 100)
$output | Add-Member -Type NoteProperty -Name SQL -Value $Query
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $Query
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$output | Add-Member -Type NoteProperty -Name NumberRecords -Value $SqlAdapter.Fill($DataSet)
$Data = $DataSet.Tables[0].Rows
$output | Add-Member -Type NoteProperty -Name EndTime -Value (Get-Date)

}catch{
throw
}
}catch{



}
Finally{
Write-Progress -Id 0 -Activity 'Exiting' -Status "Closing Connection" -CurrentOperation $computer -PercentComplete ( 3/5 * 100)
if ($SqlConnection -and $SqlConnection.State -eq [System.Data.ConnectionState]::Open)
{
$SqlConnection.Close()
$SqlConnection.dispose()



}
$output | Add-Member -Type NoteProperty -Name RunDuration -Value (New-TimeSpan -Start $output.StartTime -End $output.EndTime)
$output | Add-Member -Type NoteProperty -Name Results -Value $Data
$output | Add-Member -Type NoteProperty -Name Error -Value $handler
}
Write-Progress -Id 0 -Activity 'Exiting' -Status "Return Value" -CurrentOperation $computer -PercentComplete (100)
#$ProgressPreference = "SilentlyContinue"
return $output



}
