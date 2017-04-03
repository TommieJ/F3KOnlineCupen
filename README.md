# OnlineCupenF3K
Här hittar du ett LUA skript till din Taranis-sändare för att hålla poängräkning för [onlinecupen F3K](http://modellsegelflyg.se/StaticContent.aspx?pageid=2337).
## Installation
Ladda hem skriptet OCF3K.lua och lägg det på SD-kortet i din Taranis i foldern '/SCRIPTS/TELEMETRY/'.
Du laddar enklast hem filen genom att klicka på filnamnet och sedan högerklicka på knappen 'Raw' uppe till höger, välj sedan 'spara som' (eller liknande, beror på om du använder Chrome, Safari, FireFox, Internet Explorer etc) till lämpligt ställe. Sen kopierar du in filen till din Taranis SD kort i foldern '/SCRIPTS/TELEMETRY/'.

## Användarinstruktioner
Tidtagning för flygningen startas med launch-switchen. Skriptet har SF som launch-switch, men det är lätt att ändra överst bland inställningarna i skriptet.
När du landar(eller fångar planet i kastpinnen) aktiverar du launch-switchen igen för att stoppa tiden.
Därefter får du en fråga om du fick landningspoäng. Landningspoängen symboliseras med en ifylld checkbox för raden för flygningen. Därefter förbereds nästa flygning.

När alla flygningar är klara sparas omgången ned på SD kortet i filen '/LOGS/OCF3K.csv'. Som standard används ';' som avskiljare (för det funkar bäst i mitt svenska excel :) , bara att öppna filen direkt), men det går att byta till valfritt tecken i skriptets inställningar högst upp i filen.

Tryck på 'Menu' knappen för att starta en ny omgång.
