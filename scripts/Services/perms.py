import os

import scripts.python.data.data_handler as handler 

from scripts.python.interface.voices.TextSpeaker import speak

from storage.config.data_paths import paths

from scripts.python.helpers.BashRunner import RunBash

path = paths()

def setpassword():

    # check if password already exists
    if os.path.exists(path.SudoPassword):
        return  # already set, skip
    
    
    speak('input sudo password', True)

    password = input('enter password: ')
    handler.text_data_write(password, path.SudoPassword)

def password():
    if not os.path.exists(path.SudoPassword):
        return None  # nothing stored yet

    return handler.text_data_load(path.SudoPassword)

def setsudopassword(password):
    RunBash(path.BashCommands + '/sudo.sh',args=[password],capture=True)

