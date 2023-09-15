#---NOTE: I did not write the original code this was based on, nor do I intend to take credit for it---#
Function Show-ADPhoto {
                
        [CmdletBinding()]             
            Param (                        
                [Parameter(Mandatory=$True, 
                    #ValueFromPipeline=$True,
                    #ValueFromPipelineByPropertyName=$True,
                    Position=0)]  
                [Alias('un')]
                [String]$UserName
            )#End: Param
        
        ##----------------------------------------------------------------------
        ##  Search AD for the user, set the path to the user account object.
        ##----------------------------------------------------------------------
        $Searcher = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
        $Searcher.Filter = "(&(ObjectClass=User)(SAMAccountName= $UserName))"
        $FoundUser = $Searcher.findOne()
        $P = $FoundUser | Select path
        Write-Verbose "Retrieving LDAP path for user $UserName ..."
        If ($FoundUser -ne $null) {
            Write-Verbose $P.Path
        }#END: If ($FoundUser -ne $null)
        Else {
            Write-Warning "User $UserName not found in this domain!"
            Write-Warning "Aborting..."
            Break;
        }#END: Else
        $User = [ADSI]$P.path
        
        ##----------------------------------------------------------------------
        ##  Build a form to display the image
        ##----------------------------------------------------------------------
        $Img = $User.Properties["thumbnailPhoto"].Value
        #$Img = $User.Properties["jpegPhoto"].Value
        [VOID][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Form = New-Object Windows.Forms.Form
        $Form.Text = "Image stored in AD for $UserName"
        $Form.AutoSize = "True"
        $Form.AutoSizeMode = "GrowAndShrink"
        $PictureBox = New-Object Windows.Forms.PictureBox
        $PictureBox.SizeMode = "AutoSize"
        $PictureBox.Image = $Img
        $Form.Controls.Add($PictureBox)
        $Form.Add_Shown({$Form.Activate()})
        $Form.ShowDialog()
    }
	#END: Function Show-ADPhoto
	End {}
