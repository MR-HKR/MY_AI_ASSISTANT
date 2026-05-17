from scripts.python.core.CommandHandler import HandleCommand

from ml.ai_text import txt_detect, load_model

from scripts.python.interface.voices.TextSpeaker import speak

import scripts.Services.perms as perms


perms.setpassword()
passwd = perms.password()
perms.setsudopassword(passwd)


def Core():
    speak('good morning master', True)

    while True:
        text = input('> ').strip()

        if not text:
            speak('enter a  command', asynch=True)

            continue

        if text.lower() in ['exit', 'quit', 'bye']:
            speak('goodbye')
            break

        try:
            parsed_text = txt_detect(text)

   


            HandleCommand(parsed_text)

        except Exception as e:
            print(f'Error: {e}')
