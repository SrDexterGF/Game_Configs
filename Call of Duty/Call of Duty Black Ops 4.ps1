        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

        # FUNCTION GET FILE FROM WEB
        function Get-FileFromWeb {
        param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
        function Show-Progress {
        param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10, [Parameter()][switch]$Complete)
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        if ($psISE) { Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete }
        else { Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " }
        }
        try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $response = $request.GetResponse()
        if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'." }
        if ($File -match '^\.\\') { $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1] }
        if ($File -and !(Split-Path $File)) { $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File }
        if ($File) { $fileDirectory = $([System.IO.Path]::GetDirectoryName($File)); if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null } }
        [long]$fullSize = $response.ContentLength
        [byte[]]$buffer = new-object byte[] 1048576
        [long]$total = [long]$count = 0
        $reader = $response.GetResponseStream()
        $writer = new-object System.IO.FileStream $File, 'Create'
        do {
        $count = $reader.Read($buffer, 0, $buffer.Length)
        $writer.Write($buffer, 0, $count)
        $total += $count
        if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
        } while ($count -gt 0)
        }
        finally {
        $reader.Close()
        $writer.Close()
        }
        }

        # FUNCTION SHOW MODERN FILE PICKER
        function Show-ModernFilePicker {
        param(
        [ValidateSet('Folder', 'File')]
        $Mode,
        [string]$fileType
        )
        if ($Mode -eq 'Folder') {
        $Title = 'Select Folder'
        $modeOption = $false
        $Filter = "Folders|`n"
        }
        else {
        $Title = 'Select File'
        $modeOption = $true
        if ($fileType) {
        $Filter = "$fileType Files (*.$fileType) | *.$fileType|All files (*.*)|*.*"
        }
        else {
        $Filter = 'All Files (*.*)|*.*'
        }
        }
        $AssemblyFullName = 'System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
        $Assembly = [System.Reflection.Assembly]::Load($AssemblyFullName)
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.AddExtension = $modeOption
        $OpenFileDialog.CheckFileExists = $modeOption
        $OpenFileDialog.DereferenceLinks = $true
        $OpenFileDialog.Filter = $Filter
        $OpenFileDialog.Multiselect = $false
        $OpenFileDialog.Title = $Title
        $OpenFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
        $OpenFileDialogType = $OpenFileDialog.GetType()
        $FileDialogInterfaceType = $Assembly.GetType('System.Windows.Forms.FileDialogNative+IFileDialog')
        $IFileDialog = $OpenFileDialogType.GetMethod('CreateVistaDialog', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $null)
        $null = $OpenFileDialogType.GetMethod('OnBeforeVistaDialog', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $IFileDialog)
        if ($Mode -eq 'Folder') {
        [uint32]$PickFoldersOption = $Assembly.GetType('System.Windows.Forms.FileDialogNative+FOS').GetField('FOS_PICKFOLDERS').GetValue($null)
        $FolderOptions = $OpenFileDialogType.GetMethod('get_Options', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $null) -bor $PickFoldersOption
        $null = $FileDialogInterfaceType.GetMethod('SetOptions', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $FolderOptions)
        }
       $VistaDialogEvent = [System.Activator]::CreateInstance($AssemblyFullName, 'System.Windows.Forms.FileDialog+VistaDialogEvents', $false, 0, $null, $OpenFileDialog, $null, $null).Unwrap()
        [uint32]$AdviceCookie = 0
        $AdvisoryParameters = @($VistaDialogEvent, $AdviceCookie)
        $AdviseResult = $FileDialogInterfaceType.GetMethod('Advise', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $AdvisoryParameters)
        $AdviceCookie = $AdvisoryParameters[1]
        $Result = $FileDialogInterfaceType.GetMethod('Show', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, [System.IntPtr]::Zero)
        $null = $FileDialogInterfaceType.GetMethod('Unadvise', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $AdviceCookie)
        if ($Result -eq [System.Windows.Forms.DialogResult]::OK) {
        $FileDialogInterfaceType.GetMethod('GetResult', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $null)
        }
        return $OpenFileDialog.FileName
        }

# message
Write-Host "Run game once to generate config location"
Write-Host ""
Pause
Clear-Host

# download config files
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/Github-Game-Configs/raw/refs/heads/main/Call%20of%20Duty/Call%20of%20Duty%20Black%20Ops%204.zip" -File "$env:SystemRoot\Temp\BO4.zip"
Clear-Host

# extract config files
Expand-Archive "$env:SystemRoot\Temp\BO4.zip" -DestinationPath "$env:SystemRoot\Temp\BO4" -ErrorAction SilentlyContinue | Out-Null
Clear-Host

# edit config files
$configini = "$env:SystemRoot\Temp\BO4\players\config.ini"

# user input change rendererworkercount in config files
Write-Host "Set RendererWorkerCount to cpu cores -1"
Write-Host ""
do {
$input = Read-Host -Prompt "RendererWorkerCount"
} while ([string]::IsNullOrWhiteSpace($input))
(Get-Content $configini) -replace "\$", $input | Out-File $configini

# convert configini to utf8
$content = Get-Content -Path "$env:SystemRoot\Temp\BO4\players\config.ini" -Raw
$filePath = "$env:SystemRoot\Temp\BO4\players\config.ini"
$encoding = New-Object System.Text.UTF8Encoding $false
$writer = [System.IO.StreamWriter]::new($filePath, $false, $encoding)
$writer.Write($content)
$writer.Close()
Clear-Host

# pick folder
Write-Host "Find 'Call of Duty Black Ops 4' install folder:"
Write-Host "In 'Call of Duty Black Ops 4\players' select 'YourID' folder:"
$ConfigFolder1 = Show-ModernFilePicker -Mode Folder
Clear-Host

# install config files
Copy-Item -Path "$env:SystemRoot\Temp\BO4\YourID\*" -Destination "$ConfigFolder1" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
$ConfigFolder1 = [System.IO.Path]::GetDirectoryName($ConfigFolder1)
Copy-Item -Path "$env:SystemRoot\Temp\BO4\players\*" -Destination "$ConfigFolder1" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Clear-Host

# cleanup
Remove-Item "$env:SystemRoot\Temp\BO4" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:SystemRoot\Temp\BO4.zip" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

# message
Write-Host "Call of Duty Black Ops 4 config applied . . ."
Write-Host ""
Write-Host "Always select 'no' for 'Set Optimal Settings & Run In Safe Mode'"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")