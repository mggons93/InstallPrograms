Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ErrorActionPreference = 'SilentlyContinue'
$wshell = New-Object -ComObject Wscript.Shell
$Button = [System.Windows.MessageBoxButton]::YesNoCancel
$ErrorIco = [System.Windows.MessageBoxImage]::Error
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Maximized
	Exit
}

Write-Host "Ocultando Actualizacion KB5005463"
Install-PackageProvider -Name Nuget -Force
Install-Module PSWindowsUpdate -Force
Hide-WindowsUpdate -KBArticleID KB5005463 -Confirm:$False


# GUI Specs
Write-Host "Checking winget..."

# Check if winget is installed
if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe){
    'Winget Already Installed'
}  
else{
    # Installing winget from the Microsoft Store
	Write-Host "Winget not found, installing it now."
    $ResultText.text = "`r`n" +"`r`n" + "Installing Winget... Please Wait"
	Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
	$nid = (Get-Process AppInstaller).Id
	Wait-Process -Id $nid
	Write-Host Winget Installed
    $ResultText.text = "`r`n" +"`r`n" + "Winget Installed - Ready for Next Task"
}

# $inputXML = Get-Content "MainWindow.xaml" #uncomment for development
$inputXML = (new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/mggons/install/main/MainWindow.xaml") #uncomment for Production

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    If ($error[0].Exception.Message -like "*button*") {
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"
    }
}
catch{# If it broke some other way <img draggable="false" role="img" class="emoji" alt="😀" src="https://s0.wp.com/wp-content/mu-plugins/wpcom-smileys/twemoji/2/svg/1f600.svg">
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        }
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
If ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 

#===========================================================================
# Tab 1 - Install
#===========================================================================
$WPFinstall.Add_Click({
    $wingetinstall = New-Object System.Collections.Generic.List[System.Object]
    If ( $WPFInstallmsvc.IsChecked -eq $true ) {
	$wingetinstall.Add("Microsoft.VCRedist.2005.x64")
	$wingetinstall.Add("Microsoft.VCRedist.2005.x86")
	$wingetinstall.Add("Microsoft.VCRedist.2008.x64")
	$wingetinstall.Add("Microsoft.VCRedist.2008.x86")
	$wingetinstall.Add("Microsoft.VCRedist.2010.x64")
	$wingetinstall.Add("Microsoft.VCRedist.2010.x86")
	$wingetinstall.Add("Microsoft.VCRedist.2012.x64")
	$wingetinstall.Add("Microsoft.VCRedist.2012.x86")
	$wingetinstall.Add("Microsoft.VCRedist.2013.x64")
	$wingetinstall.Add("Microsoft.VCRedist.2013.x86")
	$wingetinstall.Add("Microsoft.VCRedist.2015.x64")
	$wingetinstall.Add("Microsoft.VCRedist.2015.x86")
	$WPFInstallmsvc.IsChecked = $false
    }
    If ( $WPFInstalldirectx.IsChecked -eq $true ) { 
        $wingetinstall.Add("Microsoft.DirectX")
        $WPFInstalldirectx.IsChecked = $false
    }
    If ( $WPFInstallterminal.IsChecked -eq $true ) { 
        $wingetinstall.Add("Microsoft.WindowsTerminal")
        $WPFInstallterminal.IsChecked = $false
    }
    If ( $WPFInstallMicrosoftOffice.IsChecked -eq $true ) { 
        $wingetinstall.Add("Microsoft.Office")
        $WPFInstallMicrosoftOffice.IsChecked = $false
    } 
    If ( $WPFInstallMicrosoftOffice2.IsChecked -eq $true ) {
     	Import-Module BitsTransfer
    	Start-BitsTransfer -Source "http://www.aionlatam.com/files/OfficeInstall.bat" -Destination C:\ODT\OfficeInstall.bat
        Start-Process C:\ODT\OfficeInstall.bat
        $WPFInstallMicrosoftOffice2.IsChecked = $false
    } 
    If ( $WPFInstallpowertoys.IsChecked -eq $true ) { 
        $wingetinstall.Add("Microsoft.PowerToys")
        $WPFInstallpowertoys.IsChecked = $false
    }
    If ( $WPFInstallteams.IsChecked -eq $true ) { 
        $wingetinstall.Add("Microsoft.Teams")
        $WPFInstallteams.IsChecked = $false
    }
    If ( $WPFInstallrustdesk.IsChecked -eq $true ) { 
        $wingetinstall.Add("RustDesk.RustDesk")
        $WPFInstallrustdesk.IsChecked = $false
    }
    If ( $WPFInstalladobe.IsChecked -eq $true ) { 
        $wingetinstall.Add("Adobe.Acrobat.Reader.64-bit")
        $WPFInstalladobe.IsChecked = $false
    }
    If ( $WPFInstallpdf24.IsChecked -eq $true ) { 
        $wingetinstall.Add("geeksoftwareGmbH.PDF24Creator")
        $WPFInstallpdf24.IsChecked = $false
    }
    If ( $WPFInstallnitro.IsChecked -eq $true ) { 
    	Import-Module BitsTransfer
	Start-BitsTransfer -Source "http://www.aionlatam.com/files/nitro.exe" -Destination C:\ODT\nitro.exe
 	Start-Process C:\ODT\nitro.exe /s
        $WPFInstallnitro.IsChecked = $false
    }
    If ( $WPFInstallavast.IsChecked -eq $true ) { 
        $wingetinstall.Add("XPDNZJFNCR1B07")
        $WPFInstallavast.IsChecked = $false
    }
    If ( $WPFInstallavg.IsChecked -eq $true ) { 
        $wingetinstall.Add("XP8BX2DWV7TF50")
        $WPFInstallavg.IsChecked = $false
    }
    If ( $WPFInstallESS.IsChecked -eq $true ) { 
        $wingetinstall.Add("ESET.Security")
        $WPFInstallESS.IsChecked = $false
    }
    If ( $WPFInstallESA.IsChecked -eq $true ) { 
        $wingetinstall.Add("ESET.Nod32")
        $WPFInstallESA.IsChecked = $false
    }
    If ( $WPFInstalladvancedip.IsChecked -eq $true ) { 
	$wingetinstall.Add("Famatech.AdvancedIPScanner")
        $WPFInstalladvancedip.IsChecked = $false
    }
    If ( $WPFInstallatom.IsChecked -eq $true ) { 
        $wingetinstall.Add("GitHub.Atom")
        $WPFInstallatom.IsChecked = $false
    }
    If ( $WPFInstallaudacity.IsChecked -eq $true ) { 
        $wingetinstall.Add("Audacity.Audacity")
        $WPFInstallaudacity.IsChecked = $false
    }
    If ( $WPFInstallautohotkey.IsChecked -eq $true ) { 
        $wingetinstall.Add("Lexikos.AutoHotkey")
        $WPFInstallautohotkey.IsChecked = $false
    }  
    If ( $WPFInstallbrave.IsChecked -eq $true ) { 
        $wingetinstall.Add("BraveSoftware.BraveBrowser")
        $WPFInstallbrave.IsChecked = $false
    }
    If ( $WPFInstallchrome.IsChecked -eq $true ) { 
        $wingetinstall.Add("Google.Chrome")
        $WPFInstallchrome.IsChecked = $false
    }
    If ( $WPFInstalldiscord.IsChecked -eq $true ) { 
        $wingetinstall.Add("Discord.Discord")
        $WPFInstalldiscord.IsChecked = $false
    }
    If ( $WPFInstallesearch.IsChecked -eq $true ) { 
        $wingetinstall.Add("voidtools.Everything --source winget")
        $WPFInstallesearch.IsChecked = $false
    }
    If ( $WPFInstalletcher.IsChecked -eq $true ) { 
        $wingetinstall.Add("Balena.Etcher")
        $WPFInstalletcher.IsChecked = $false
    }
    If ( $WPFInstallfirefox.IsChecked -eq $true ) { 
        $wingetinstall.Add("Mozilla.Firefox")
        $WPFInstallfirefox.IsChecked = $false
    }
    If ( $WPFInstallgimp.IsChecked -eq $true ) { 
        $wingetinstall.Add("GIMP.GIMP")
        $WPFInstallgimp.IsChecked = $false
    }
    If ( $WPFInstallgithubdesktop.IsChecked -eq $true ) { 
        $wingetinstall.Add("Git.Git")
        $wingetinstall.Add("GitHub.GitHubDesktop")
        $WPFInstallgithubdesktop.IsChecked = $false
    }
    If ( $WPFInstallimageglass.IsChecked -eq $true ) { 
        $wingetinstall.Add("DuongDieuPhap.ImageGlass")
        $WPFInstallimageglass.IsChecked = $false
    }
    If ( $WPFInstalljava8SE.IsChecked -eq $true ) { 
        $wingetinstall.Add("Oracle.JavaRuntimeEnvironment")
        $WPFInstalljava8SE.IsChecked = $false
    }
    If ( $WPFInstalljava16.IsChecked -eq $true ) { 
        $wingetinstall.Add("AdoptOpenJDK.OpenJDK.16")
        $WPFInstalljava16.IsChecked = $false
    }
    If ( $WPFInstalljava18.IsChecked -eq $true ) { 
        $wingetinstall.Add("Oracle.JDK.18")
        $WPFInstalljava18.IsChecked = $false
    }
    If ( $WPFInstalljetbrains.IsChecked -eq $true ) { 
        $wingetinstall.Add("JetBrains.Toolbox")
        $WPFInstalljetbrains.IsChecked = $false
    }
    If ( $WPFInstallmpc.IsChecked -eq $true ) { 
        $wingetinstall.Add("clsid2.mpc-hc")
        $WPFInstallmpc.IsChecked = $false
    }
    If ( $WPFInstallnodejs.IsChecked -eq $true ) { 
        $wingetinstall.Add("OpenJS.NodeJS")
        $WPFInstallnodejs.IsChecked = $false
    }
    If ( $WPFInstallnodejslts.IsChecked -eq $true ) { 
        $wingetinstall.Add("OpenJS.NodeJS.LTS")
        $WPFInstallnodejslts.IsChecked = $false
    }
    If ( $WPFInstallnotepadplus.IsChecked -eq $true ) { 
        $wingetinstall.Add("Notepad++.Notepad++")
        $WPFInstallnotepadplus.IsChecked = $false
    }
    If ( $WPFInstallputty.IsChecked -eq $true ) { 
        $wingetinstall.Add("PuTTY.PuTTY")
        $WPFInstallputty.IsChecked = $false
    }
    If ( $WPFInstallpython3.IsChecked -eq $true ) { 
        $wingetinstall.Add("Python.Python.3")
        $WPFInstallpython3.IsChecked = $false
    }
    If ( $WPFInstallsevenzip.IsChecked -eq $true ) { 
        $wingetinstall.Add("7zip.7zip")
        $WPFInstallsevenzip.IsChecked = $false
    }
    If ( $WPFInstallsharex.IsChecked -eq $true ) { 
        $wingetinstall.Add("ShareX.ShareX")
        $WPFInstallsharex.IsChecked = $false
    }
    If ( $WPFInstallsublime.IsChecked -eq $true ) { 
        $wingetinstall.Add("SublimeHQ.SublimeText.4")
        $WPFInstallsublime.IsChecked = $false
    }
    If ( $WPFInstallwpsoffice.IsChecked -eq $true ) { 
        $wingetinstall.Add("Kingsoft.WPSOffice")
        $WPFInstallwpsoffice.IsChecked = $false
    }
    If ( $WPFInstallttaskbar.IsChecked -eq $true ) { 
        $wingetinstall.Add("TranslucentTB.TranslucentTB")
        $WPFInstallttaskbar.IsChecked = $false
    }
    If ( $WPFInstallvlc.IsChecked -eq $true ) { 
        $wingetinstall.Add("XPDM1ZW6815MQM")
        $WPFInstallvlc.IsChecked = $false
    }
    If ( $WPFInstallvscode.IsChecked -eq $true ) { 
        $wingetinstall.Add("Git.Git")
        $wingetinstall.Add("Microsoft.VisualStudioCode --source winget")
        $WPFInstallvscode.IsChecked = $false
    }
    If ( $WPFInstallvscodium.IsChecked -eq $true ) { 
        $wingetinstall.Add("Git.Git")
        $wingetinstall.Add("VSCodium.VSCodium")
        $WPFInstallvscodium.IsChecked = $false
    }
    If ( $WPFInstallwinscp.IsChecked -eq $true ) { 
        $wingetinstall.Add("WinSCP.WinSCP")
        $WPFInstallputty.IsChecked = $false
    }
    If ( $WPFInstallbitwarden.IsChecked -eq $true ) { 
        $wingetinstall.Add("Bitwarden.Bitwarden")
        $WPFInstallbitwarden.IsChecked = $false
    }        
    If ( $WPFInstallblender.IsChecked -eq $true ) { 
        $wingetinstall.Add("BlenderFoundation.Blender")
        $WPFInstallblender.IsChecked = $false
    }                    
    If ( $WPFInstallchromium.IsChecked -eq $true ) { 
        $wingetinstall.Add("eloston.ungoogled-chromium")
        $WPFInstallchromium.IsChecked = $false
    }             
    If ( $WPFInstallcpuz.IsChecked -eq $true ) { 
        $wingetinstall.Add("CPUID.CPU-Z")
        $WPFInstallcpuz.IsChecked = $false
    }                            
    If ( $WPFInstalleartrumpet.IsChecked -eq $true ) { 
        $wingetinstall.Add("File-New-Project.EarTrumpet")
        $WPFInstalleartrumpet.IsChecked = $false
    }           
    If ( $WPFInstallepicgames.IsChecked -eq $true ) { 
        $wingetinstall.Add("EpicGames.EpicGamesLauncher")
        $WPFInstallepicgames.IsChecked = $false
    }                                      
    If ( $WPFInstallflameshot.IsChecked -eq $true ) { 
        $wingetinstall.Add("Flameshot.Flameshot")
        $WPFInstallflameshot.IsChecked = $false
    }            
    If ( $WPFInstallfoobar.IsChecked -eq $true ) { 
        $wingetinstall.Add("PeterPawlowski.foobar2000")
        $WPFInstallfoobar.IsChecked = $false
    }                     
    If ( $WPFInstallgog.IsChecked -eq $true ) { 
        $wingetinstall.Add("GOG.Galaxy")
        $WPFInstallgog.IsChecked = $false
    }                  
    If ( $WPFInstallgpuz.IsChecked -eq $true ) { 
        $wingetinstall.Add("TechPowerUp.GPU-Z")
        $WPFInstallgpuz.IsChecked = $false
    }                 
    If ( $WPFInstallgreenshot.IsChecked -eq $true ) { 
        $wingetinstall.Add("Greenshot.Greenshot")
        $WPFInstallgreenshot.IsChecked = $false
    }            
    If ( $WPFInstallhandbrake.IsChecked -eq $true ) { 
        $wingetinstall.Add("HandBrake.HandBrake")
        $WPFInstallhandbrake.IsChecked = $false
    }      
    If ( $WPFInstallhexchat.IsChecked -eq $true ) { 
        $wingetinstall.Add("HexChat.HexChat")
        $WPFInstallhexchat.IsChecked = $false
    }       
    If ( $WPFInstallhwinfo.IsChecked -eq $true ) { 
        $wingetinstall.Add("REALiX.HWiNFO")
        $WPFInstallhwinfo.IsChecked = $false
    }                       
    If ( $WPFInstallinkscape.IsChecked -eq $true ) { 
        $wingetinstall.Add("Inkscape.Inkscape")
        $WPFInstallinkscape.IsChecked = $false
    }             
    If ( $WPFInstallkeepass.IsChecked -eq $true ) { 
        $wingetinstall.Add("KeePassXCTeam.KeePassXC")
        $WPFInstallkeepass.IsChecked = $false
    }              
    If ( $WPFInstalllibreoffice.IsChecked -eq $true ) { 
        $wingetinstall.Add("TheDocumentFundation.LibreOffice")
        $WPFInstalllibreoffice.IsChecked = $false
    }
    If ( $WPFInstallmalwarebytes.IsChecked -eq $true ) { 
        $wingetinstall.Add("Malwarebytes.Malwarebytes")
        $WPFInstallmalwarebytes.IsChecked = $false
    }          
    If ( $WPFInstallmatrix.IsChecked -eq $true ) { 
        $wingetinstall.Add("Element.Element")
        $WPFInstallmatrix.IsChecked = $false
    } 
    If ( $WPFInstallmremoteng.IsChecked -eq $true ) { 
        $wingetinstall.Add("mRemoteNG.mRemoteNG")
        $WPFInstallmremoteng.IsChecked = $false
    }                    
    If ( $WPFInstallnvclean.IsChecked -eq $true ) { 
        $wingetinstall.Add("TechPowerUp.NVCleanstall")
        $WPFInstallnvclean.IsChecked = $false
    }              
    If ( $WPFInstallobs.IsChecked -eq $true ) { 
        $wingetinstall.Add("OBSProject.OBSStudio")
        $WPFInstallobs.IsChecked = $false
    }                  
    If ( $WPFInstallobsidian.IsChecked -eq $true ) { 
        $wingetinstall.Add("Obsidian.Obsidian")
        $WPFInstallobsidian.IsChecked = $false
    }                           
    If ( $WPFInstallrevo.IsChecked -eq $true ) { 
        $wingetinstall.Add("RevoUninstaller.RevoUninstaller")
        $WPFInstallrevo.IsChecked = $false
    }                 
    If ( $WPFInstallrufus.IsChecked -eq $true ) { 
        $wingetinstall.Add("Rufus.Rufus")
        $WPFInstallrufus.IsChecked = $false
    }   
    If ( $WPFInstallsignal.IsChecked -eq $true ) { 
        $wingetinstall.Add("OpenWhisperSystems.Signal")
        $WPFInstallsignal.IsChecked = $false
    }
     If ( $WPFInstallskype.IsChecked -eq $true ) { 
        $wingetinstall.Add("Microsoft.Skype")
        $WPFInstallskype.IsChecked = $false
    }                               
    If ( $WPFInstallslack.IsChecked -eq $true ) { 
        $wingetinstall.Add("SlackTechnologies.Slack")
        $WPFInstallslack.IsChecked = $false
    }                
    If ( $WPFInstallspotify.IsChecked -eq $true ) { 
        $wingetinstall.Add("Spotify.Spotify")
        $WPFInstallspotify.IsChecked = $false
    }              
    If ( $WPFInstallsteam.IsChecked -eq $true ) { 
        $wingetinstall.Add("Valve.Steam")
        $WPFInstallsteam.IsChecked = $false
    }                                              
    If ( $WPFInstalltreesize.IsChecked -eq $true ) { 
        $wingetinstall.Add("JAMSoftware.TreeSize.Free")
        $WPFInstalltreesize.IsChecked = $false
    }                         
    If ( $WPFInstallvisualstudio.IsChecked -eq $true ) { 
        $wingetinstall.Add("Microsoft.VisualStudio.2022.Community")
        $WPFInstallvisualstudio.IsChecked = $false
    }         
    If ( $WPFInstallvivaldi.IsChecked -eq $true ) { 
        $wingetinstall.Add("VivaldiTechnologies.Vivaldi")
        $WPFInstallvivaldi.IsChecked = $false
    }                              
    If ( $WPFInstallvoicemeeter.IsChecked -eq $true ) { 
        $wingetinstall.Add("VB-Audio.Voicemeeter")
        $WPFInstallvoicemeeter.IsChecked = $false
    }                    
    If ( $WPFInstallwindirstat.IsChecked -eq $true ) { 
        $wingetinstall.Add("WinDirStat.WinDirStat")
        $WPFInstallwindirstat.IsChecked = $false
    }           
    If ( $WPFInstallwireshark.IsChecked -eq $true ) { 
        $wingetinstall.Add("WiresharkFoundation.Wireshark")
        $WPFInstallwireshark.IsChecked = $false
    }            
    If ( $WPFInstallzoom.IsChecked -eq $true ) { 
        $wingetinstall.Add("Zoom.Zoom")
        $WPFInstallzoom.IsChecked = $false
    }
    If ( $WPFInstallanydesk.IsChecked -eq $true ) { 
        $wingetinstall.Add("AnyDeskSoftwareGmbH.AnyDesk")
        $WPFInstallanydesk.IsChecked = $false
    }
    If ( $WPFInstallteamviewer.IsChecked -eq $true ) { 
        $wingetinstall.Add("TeamViewer.TeamViewer")
        $WPFInstallteamviewer.IsChecked = $false
    }
    If ( $exit.IsChecked -eq $true ) { 
        ("exit")
        $exit.IsChecked = $false
    }

    # Install all winget programs in new window
    $wingetinstall.ToArray()
    # Define Output variable
    $wingetResult = New-Object System.Collections.Generic.List[System.Object]
    foreach ( $node in $wingetinstall )
    {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command winget install -e --accept-source-agreements --accept-package-agreements --force $node | Out-Host" -Wait -WindowStyle Maximized
        $wingetResult.Add("$node`n")
    }
    $wingetResult.ToArray()
    $wingetResult | % { $_ } | Out-Host
    # Popup after finished
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "Programas Instalados correctamente"
    $Messageboxbody = ($wingetResult)
    $MessageIcon = [System.Windows.MessageBoxImage]::Information
    [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$MessageIcon)

})

$WPFInstallUpgrade.Add_Click({
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-command winget upgrade --all  | Out-Host" -Wait -WindowStyle Maximized
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "ACTUALIZANDO TODOS LOS PROGRAMAS"
    $Messageboxbody = ("COMPLETADO")
    $MessageIcon = [System.Windows.MessageBoxImage]::Information

    [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$MessageIcon)
})

#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null
