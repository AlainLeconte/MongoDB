@Echo OFF
@Echo Launching Powershell as Administrator to execute script : 
@Echo %1
::powershell -NoProfile -ExecutionPolicy Bypass -file %1 %2 %3 %4 %5
Powershell -NoProfile -ExecutionPolicy Bypass -command "start-process -Wait -Verb runAs powershell" "'-NoProfile -ExecutionPolicy Bypass -File %1 %2 %3 %4 %5'"
@Echo.
@Echo Powershell ended.
timeout /t 3
::PAUSE
