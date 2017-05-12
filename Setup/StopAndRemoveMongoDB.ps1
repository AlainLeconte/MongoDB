param(
	[string]$Path = $(Get-Location),
    [int]$Quiet = 0
)

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

# Determines if a Service exists with a name as defined in $ServiceName.
# Returns a boolean $True or $False.
Function ServiceExists([string] $ServiceName) {
    [bool] $Return = $False
    # If you use just "Get-Service $ServiceName", it will return an error if 
    # the service didn't exist.  Trick Get-Service to return an array of 
    # Services, but only if the name exactly matches the $ServiceName.  
    # This way you can test if the array is emply.
    if ( Get-Service "$ServiceName*" -Include $ServiceName ) {
        $Return = $True
    }
    Return $Return
}

Function UninstallMongoDB (
    [string]$Path,
    [string]$ServiceName
)
{
	Write-Host
	Write-Host-H2 -Message "func UninstallMongoDB"
    foreach ($key in $MyInvocation.BoundParameters.keys)
    {
        $value = (get-variable $key).Value 
        Write-Host-Param -ParamName $key -Value $value
    }

    Try {
        if (ServiceExists -ServiceName $ServiceName)
        {
            Write-Host
            Write-Host $ServiceName service should be stopped and removed ... -ForegroundColor Black -BackgroundColor White
            & sc.exe stop $ServiceName
            Write-Host $ServiceName service stopped -ForegroundColor Green
            & sc.exe delete $ServiceName
            Write-Host $ServiceName service removed -ForegroundColor Green
    	    Write-Host
            Write-Host Uninstalling MongoDB to $Path ... -ForegroundColor Black -BackgroundColor White
            Start-Process msiexec.exe -Wait -ArgumentList " /q /uninstall $PSScriptRoot\mongodb-win32-x86_64-2008plus-ssl-3.4.4-signed.msi INSTALLLOCATION=`"$Path`" ADDLOCAL=`"Server,Router,Client`""
            Write-Host MondoDB Uninstalled -ForegroundColor Green
        }
        else 
        {
            Write-Host
            Write-Host $ServiceName service does not exists. -ForegroundColor Green
        }
    }
    Catch
    {
        Write-Warning $_.Exception.Message
        throw  
    }
}


Function RemoveMongoDBData (
    [string]$Path
)
{
	Write-Host
	Write-Host-H2 -Message "func RemoveMongoDB"
    foreach ($key in $MyInvocation.BoundParameters.keys)
    {
        $value = (get-variable $key).Value 
        Write-Host-Param -ParamName $key -Value $value
    }
	Write-Host
    Write-Host Removing MongoDB from $Path ... -ForegroundColor Black -BackgroundColor White
    Try {

        if (Test-Path $cd\data)
        {
            Write-Host
            Write-Host Removing existing $cd\data folder... -ForegroundColor Black -BackgroundColor White
            Remove-Item $cd\data -Force -Recurse -ErrorAction Stop
            Write-Host $cd\data folder removed -ForegroundColor Green
        }

        
        if (Test-Path $cd\mongod.cfg)
        {
            Write-Host
            Write-Host Deleting $cd\mongod.cfg configuration file... -ForegroundColor Black -BackgroundColor White
            Remove-Item $cd\mongod.cfg -Force
            Write-Host $cdt\mongod.cfg deleted -ForegroundColor Green
        }
    }
    Catch
    {
        Write-Warning $_.Exception.Message
        throw  
    }
}


Clear-Host
$cd = $(Get-Location)

Write-Host-H1 -Message "Stop and Remove MongoDB Service"

Write-Host-Param -ParamName "Script file root" -Value $PSScriptRoot
Write-Host-Param -ParamName "Current directory" -Value $cd
foreach ($key in $MyInvocation.BoundParameters.keys)
{
    $value = (get-variable $key).Value 
    Write-Host-Param -ParamName $key -Value $value
}
Write-Host

try {
    $answer = ProceedYN "Stop and Remove MongoDB Service?"
    if ($answer -eq $true) 
    {
        UninstallMongoDB -Path $Path -ServiceName "MongoDB344"
        RemoveMongoDBData -Path $Path

    }
}
catch {
    Write-Error $_.Exception.Message
    Pause
}
