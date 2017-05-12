@Echo OFF
powershell -NoProfile -ExecutionPolicy Bypass -file %1 %2 %3 %4 %5
timeout /t 10
::PAUSE
