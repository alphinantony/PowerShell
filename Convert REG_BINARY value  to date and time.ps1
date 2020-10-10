#converting MS Defender AV signature update date (from REG_BINARY) to readable format 
$RegValue = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Signature Updates"
$SigLastUpdt = $RegValue.SignaturesLastUpdated
$Int64ValueFn = [System.BitConverter]::ToInt64($SigLastUpdt, 0)
$AVSigUptDate = [DateTime]::FromFileTime($Int64ValueFn)
$AVSigUptDate

