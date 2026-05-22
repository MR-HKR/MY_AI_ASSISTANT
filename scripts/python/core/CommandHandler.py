from pathlib import Path

from scripts.python.helpers.BashRunner import RunBash

from storage.config.data_paths import paths

from scripts.python.interface.voices.TextSpeaker import speak

newsservice =paths.ServicesPath + '/News_Service.py'


def run_script(script_name, args=None,health = False):

    if health:
        script = Path(paths.HealthBashCommands) / script_name

    else:
        script = Path(paths.BashCommands) / script_name

    return RunBash(str(script), args)


def cleandisk():

    run_script('clean.sh')


def pchealthcheck():

    run_script('healthchk.sh',health=True)


def testinternet():

    run_script('internet_test.sh')


def music(state=False):

    if state:
        action = 'play'
        speak('ok playing it', asynch=True)
    else:
        action = 'pause'
        speak('stopped',asynch=True)

    

    run_script('music.sh', [action])



def News():
    run_script('open_terminal.sh',[paths.MainScriptFolder, newsservice])






def HandleCommand(label):

    match label:

        case 'clean':
            speak('gonna clean youre pc master',True)
            cleandisk()

        case 'help':
            speak('nah cant do that...... sir..... sorry', True)

        case 'healthchk':
            pchealthcheck()
        
        case 'internet_test':
            speak('checking internet...',True)
            testinternet()

        case 'play_music':
            music(state=True)

        case 'pause_music':
            music(state=False)
        
        case 'news':
            speak('calling the reporter')
            News()

        case 'unknown':
            speak('wrong command', asynch=True)
        


        
