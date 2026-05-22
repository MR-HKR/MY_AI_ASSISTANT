
from pathlib import Path

main_dir = Path(__file__).parents[2]  # goes up 2 levels from config/




class paths:
    SharedScriptText = 'storage/shared/userinput.json'
    BashCommands = 'scripts/bash/commands'
    HealthBashCommands = BashCommands + '/healthcommands'
    SudoPassword = 'storage/config/sudopass.json'
    MainScriptFolder = main_dir
    ServicesPath = str(main_dir) + '/scripts/Services'






    