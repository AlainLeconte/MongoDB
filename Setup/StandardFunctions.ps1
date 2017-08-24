Function Pause (
    $Message = "(PS) Press any key to continue . . . "
){
    if ((Test-Path variable:psISE) -and $psISE) {
        $Shell = New-Object -ComObject "WScript.Shell"
        $Button = $Shell.Popup("Click OK to continue.", 0, "Script Paused", 0)
    }
    else {     
        Write-Host -NoNewline $Message
        [void][System.Console]::ReadKey($true)
        Write-Host
    }
}


Function Write-Host-H1(
    [string]$Message
){
    Write-Host -NoNewline "---" -ForegroundColor White -BackgroundColor Green
    Write-Host -NoNewline " $Message "
    Write-Host "----" -ForegroundColor White -BackgroundColor Green
}


Function Write-Host-H2(
    [string]$Message
){
    Write-Host -NoNewline "---" -ForegroundColor White -BackgroundColor Blue
    Write-Host -NoNewline " $Message "
    Write-Host "----" -ForegroundColor White -BackgroundColor Blue
}

Function Write-Host-Param(
    [string]$ParamName,
    [string]$Value
){
    Write-Host -NoNewline "  >" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host -NoNewline "$ParamName -> "
    Write-Host $Value -ForegroundColor White
}

Function ProceedYN (
    [string]$Message
) {
    if ($Quiet -eq 1) {return $true}
    $answer = Read-Host "$Message (y/n)"
    return ($answer -eq 'y')
}