param(
	[string]$mongoDbPath = ($PSScriptRoot | split-path -parent),
    [string]$mongoDbServiceName = "MongoDB347",
    [int]$Quiet = 0,
    [int]$clearHost = 1
)

# Load functions
$stdFuntionsPath = (split-path -parent $PSCommandPath)
. "$stdFuntionsPath\StandardFunctions.ps1"

# Global params
$mongoMsi = "mongodb-win32-x86_64-2008plus-ssl-v3.4-latest-signed.msi"
#$mongoMsi = "mongodb-win32-x86_64-2008plus-ssl-2.8.0-rc5-signed.msi"

$url = "http://downloads.mongodb.org/win32/$mongoMsi"


Function UninstallMongoDB (
    [string]$mongoDbPath,
    [string]$mongoDbServiceName
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
        $msiFile =  "$mongoDbPath\$mongoMsi" 

        if (ServiceExists -ServiceName $mongoDbServiceName)
        {
            Write-Host
            Write-Host $mongoDbServiceName service should be stopped and removed ... -ForegroundColor Black -BackgroundColor White
            & sc.exe stop $mongoDbServiceName
            Write-Host $mongoDbServiceName service stopped -ForegroundColor Green
            & sc.exe delete $mongoDbServiceName
            Write-Host $mongoDbServiceName service removed -ForegroundColor Green
    	    
            if (Test-Path $msiFile) {
                Write-Host
                Write-Host Uninstalling MongoDB ($msiFile) from $mongoDbPath ... -ForegroundColor Black -BackgroundColor White
                Start-Process msiexec.exe -Wait -ArgumentList " /q /uninstall $msiFile INSTALLLOCATION=`"$mongoDbPath`" ADDLOCAL=`"Server,Router,Client`""
                Write-Host MondoDB Uninstalled -ForegroundColor Green
            }
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

    Write-Host msiexec.exe -Wait -ArgumentList " /q /uninstall /i $msiFile INSTALLLOCATION=`"$mongoDbPath`" ADDLOCAL=`"Server,Router,Client`""
}


Function RemoveMongoDBData (
    [string]$mongoDbPath
)
{
	Write-Host
	Write-Host-H2 -Message "func RemoveMongoDBData"
    foreach ($key in $MyInvocation.BoundParameters.keys)
    {
        $value = (get-variable $key).Value 
        Write-Host-Param -ParamName $key -Value $value
    }
	Write-Host
    Write-Host Removing MongoDB from $mongoDbPath ... -ForegroundColor Black -BackgroundColor White
    Try {

        if (Test-Path $mongoDbPath\data)
        {
            Write-Host
            Write-Host Removing existing $cd\data folder... -ForegroundColor Black -BackgroundColor White
            Remove-Item $mongoDbPath\data -Force -Recurse -ErrorAction Stop
            Write-Host $mongoDbPath\data folder removed -ForegroundColor Green
        }
        else 
        {
            Write-Host No $cd\data folder to remove
        }

        
        if (Test-Path $mongoDbPath\mongod.cfg)
        {
            Write-Host
            Write-Host Deleting $mongoDbPath\mongod.cfg configuration file... -ForegroundColor Black -BackgroundColor White
            Remove-Item $mongoDbPath\mongod.cfg -Force -ErrorAction Stop
            Write-Host $mongoDbPath\mongod.cfg file deleted -ForegroundColor Green
        }
        else 
        {
            Write-Host No $mongoDbPath\mongod.cfg configuration file to remove
        }

        if (Test-Path $mongoDbPath)
        {
            Write-Host
            Write-Host Deleting $mongoDbPath folder... -ForegroundColor Black -BackgroundColor White
            Remove-Item $mongoDbPath -Force -Recurse -ErrorAction Stop
            Write-Host $mongoDbPath folder deleted -ForegroundColor Green
        }
        else 
        {
            Write-Host No $mongoDbPath folder to remove
        }

    }
    Catch
    {
        Write-Warning $_.Exception.Message
        throw  
    }

    Write-Host MongoDB from $mongoDbPath removed -ForegroundColor Green
}


if ($clearHost -eq 1) {
    Clear-Host
}
#$cd = $(Get-Location)
$cd = ($PSScriptRoot | split-path -parent)

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
        UninstallMongoDB -mongoDbPath $mongoDbPath -mongoDbServiceName $mongoDbServiceName
        RemoveMongoDBData -mongoDbPath $mongoDbPath

    }
    pause
}
catch {
    Write-Error $_.Exception.Message
    Pause
}
