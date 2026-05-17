from scripts.python.helpers.BashRunner import RunBash

from storage.config.data_paths import paths

Path = paths()
speaksh = Path.BashCommands + '/speak.sh'

def speak(text, asynch=False):
    RunBash(speaksh, args=[text], capture=False)
