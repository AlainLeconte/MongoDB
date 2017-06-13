param(
	[string]$Path = ($PSScriptRoot | split-path -parent),
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


Function InstallMongoDB (
    [string]$Path
)
{
	Write-Host
	Write-Host-H2 -Message "func InstallMongoDB"
    foreach ($key in $MyInvocation.BoundParameters.keys)
    {
        $value = (get-variable $key).Value 
        Write-Host-Param -ParamName $key -Value $value
    }
	Write-Host
    Write-Host Installing MongoDB to $Path ... -ForegroundColor Black -BackgroundColor White
    Try {
        Start-Process msiexec.exe -Wait -ArgumentList " /q /i $PSScriptRoot\mongodb-win32-x86_64-2008plus-ssl-3.4.4-signed.msi INSTALLLOCATION=`"$Path`" ADDLOCAL=`"Server,Router,Client`""
        Write-Host MondoDB installed -ForegroundColor Green
    }
    Catch
    {
        Write-Warning $_.Exception.Message
        throw  
    }
}

Function ConfigureMongoDB (
    [string]$Path,
    [string]$ServiceName
)
{
	Write-Host
	Write-Host-H2 -Message "func ConfigureMongoDB"
    foreach ($key in $MyInvocation.BoundParameters.keys)
    {
        $value = (get-variable $key).Value 
        Write-Host-Param -ParamName $key -Value $value
    }
	Write-Host
    Write-Host Configuring MongoDB to $Path ... -ForegroundColor Black -BackgroundColor White


    Try {
        if (ServiceExists -ServiceName $ServiceName)
        {
            Write-Host $ServiceName service should be stopped and removed ... -ForegroundColor Black -BackgroundColor White
            & sc.exe stop $ServiceName
            & sc.exe delete $ServiceName
            Write-Host $ServiceName service removed -ForegroundColor Green
        }


        if (Test-Path $cd\data)
        {
            Write-Host
            Write-Host Removing existing $cd\data folder... -ForegroundColor Black -BackgroundColor White
            Remove-Item $cd\data -Force -Recurse -ErrorAction Stop
            Write-Host $cd\data folder removed -ForegroundColor Green
        }
        Write-Host
        Write-Host Creating $cd\data folders... -ForegroundColor Black -BackgroundColor White
        New-Item $Path\data\db -type directory -Force
        New-Item $Path\data\log -type directory -Force
        Write-Host $cd\data folder created -ForegroundColor Green

        $ConfigPath = "$cd\mongod.cfg" 

        Write-Host
        Write-Host Copying $PSScriptRoot\mongod.cfg configuration file to $ConfigPath... -ForegroundColor Black -BackgroundColor White
        Copy-Item $PSScriptRoot\mongod.cfg $ConfigPath -Force
        Write-Host $PSScriptRoot\mongod.cfg copied to $ConfigPath -ForegroundColor Green
        
        Write-Host
        Write-Host Updating $ConfigPath configuration file... -ForegroundColor Black -BackgroundColor White
        (Get-Content $ConfigPath) -replace "<CurrentDrivePath>",$cd | Set-Content $ConfigPath         
        Write-Host $ConfigPath updated -ForegroundColor Green

        Write-Host
        Write-Host Configuring $ServiceName service ... -ForegroundColor Black -BackgroundColor White
        & "$cd\bin\mongod" --config $cd\mongod.cfg --install --serviceName MongoDB344 --serviceDisplayName MongoDB344
        Write-Host $ServiceName service configured -ForegroundColor Green

        if (ServiceExists -ServiceName $ServiceName)
        {
            Write-Host Starting $ServiceName service ... -ForegroundColor Black -BackgroundColor White
            & net start $ServiceName
            Write-Host $ServiceName service started -ForegroundColor Green
        }

        Write-Host MongoDB configured and started -ForegroundColor Green
    }
    Catch
    {
        Write-Warning $_.Exception.Message
        throw  
    }
}


Clear-Host
#$cd = $(Get-Location)
$cd = $PSScriptRoot | split-path -parent

Write-Host-H1 -Message "Install MongoDB Service"

Write-Host-Param -ParamName "Script file root" -Value $PSScriptRoot
Write-Host-Param -ParamName "Current directory" -Value $cd
foreach ($key in $MyInvocation.BoundParameters.keys)
{
    $value = (get-variable $key).Value 
    Write-Host-Param -ParamName $key -Value $value
}
Write-Host

try {
    $answer = ProceedYN "Install MongoDB Service?"
    if ($answer -eq $true) 
    {
        InstallMongoDB -Path $Path 
        ConfigureMongoDB -Path $Path -ServiceName "MongoDB344"

    }
}
catch {
    Write-Error $_.Exception.Message
    Pause
}
