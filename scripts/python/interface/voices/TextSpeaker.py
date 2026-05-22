from scripts.python.helpers.BashRunner import RunBash

from storage.config.data_paths import paths

Path = paths()
speaksh = Path.BashCommands

def speak(text, asynch=False):
    RunBash(speaksh + '/speak.sh', args=[text], capture=False)

def speak2(text, asynch=False):
    RunBash(speaksh + '/speak2.sh', args=[text], capture=False)





