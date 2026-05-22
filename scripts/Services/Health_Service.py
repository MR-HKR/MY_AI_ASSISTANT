from scripts.python.interface.voices.TextSpeaker import speak

from storage.config.data_paths import paths 

from pathlib import Path

from scripts.python.helpers.BashRunner import RunBash

from scripts.python.interface.input_handler import interface 


text_input = interface()

def run_script(script_name, args=None):


    script = Path(paths.HealthBashCommands) / script_name

    return RunBash(str(script), args)


def Health_Service():

    
    text_input.text_interface()

    print(text_input.message)                   
    pass                       

    




