$RegValue = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Signature Updates"
$shutDown = $RegValue.SignaturesLastUpdated
$Int64Value = [System.BitConverter]::ToInt64($shutDown, 0)
$date = [DateTime]::FromFileTime($Int64Value)

$date

