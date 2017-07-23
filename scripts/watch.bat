@echo off

echo INFO: Watching Jekyll development website on http://localhost:3000

browser-sync start -s %cd%\src\_site -f %cd%\src\_site --reload-delay 300 --no-open
