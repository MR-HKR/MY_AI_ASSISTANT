from scripts.python.core.CommandHandler import HandleCommand

from ml.ai_text import txt_detect, load_model

from scripts.python.interface.voices.TextSpeaker import speak

from scripts.python.interface.input_handler import interface

import scripts.Services.perms as perms


perms.setpassword()
passwd = perms.password()
perms.setsudopassword(passwd)
text_input = interface()


def Core():
    speak('good morning master', True)

    while True:
        text_input.text_interface()

        if not text_input.text:
            speak('enter a  command', asynch=True)

            continue

        if text_input.text.lower() in ['exit', 'quit', 'bye']:
            speak('goodbye')
            break

        try:
            parsed_text = txt_detect(text_input.text)

   


            HandleCommand(parsed_text)

        except Exception as e:
            print(f'Error: {e}')
