
$date=(get-date).ToString("dd-MMM-yy")
$folder=Test-Path "c:\def\$($date)"
if ($folder -ne 'true' ) 
{
    New-Item -Path "c:\def\" -ItemType Directory -Name (get-date).ToString("dd-MMM-yy")
}
else 
{
    "nis_x86.exe","nis_x64.exe","mpam_x86.exe","mpam_x64.exe" | ForEach-Object `
    {
        $path="c:\def\$($date)\$_"
        if((Test-Path $path) -eq 'true')
            {
                Remove-Item -Path $path -Force -ErrorAction Stop
            }
    }
}
Invoke-WebRequest "https://go.microsoft.com/fwlink/?LinkID=187316&arch=x86&nri=true" -OutFile "c:\def\$($date)\nis_x86.exe"
Invoke-WebRequest "https://go.microsoft.com/fwlink/?LinkID=187316&arch=x64&nri=true" -OutFile "c:\def\$($date)\nis_x64.exe"
Invoke-WebRequest "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x86" -OutFile "c:\def\$($date)\mpam_x86.exe"
Invoke-WebRequest "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64" -OutFile "c:\def\$($date)\mpam_x64.exe"

Get-ChildItem -Path "c:\def\" | Where-Object {$_.LastWriteTime -le $(get-date).AddDays(-2) } | Remove-Item -Recurse -Force

    


 

   


