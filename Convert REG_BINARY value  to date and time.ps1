#converting MS Defender AV signature update date (from REG_BINARY) to readable format 
$RegValue = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Signature Updates"
$SigLastUpdt = $RegValue.SignaturesLastUpdated
$Int64Value = [System.BitConverter]::ToInt64($SigLastUpdt, 0)
$date = [DateTime]::FromFileTime($Int64Value)

$date

