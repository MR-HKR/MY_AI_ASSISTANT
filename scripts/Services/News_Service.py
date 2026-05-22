import feedparser

from html import unescape

import re

import time

from langdetect import detect

from scripts.python.interface.voices.TextSpeaker_Fancy import fancy_speak

from storage.config.sources import SOURCES

EN_VOICE = 'en-PH-RosaNeural'
FIL_VOICE = 'fil-PH-BlessicaNeural'

def get_voice(text):
    try:
        return FIL_VOICE if detect(text) == 'tl' else EN_VOICE
    except Exception:
        return EN_VOICE

def clean_html(text):
    text = re.sub(r'<[^>]+>', '', text)
    return unescape(text).strip()

def format_date(entry):
    date_struct = getattr(entry, 'published_parsed', None)
    if date_struct:
        return time.strftime('%b %d, %Y - %I:%M %p', date_struct)
    return (
        getattr(entry, 'published', None)
        or getattr(entry, 'updated', None)
        or 'No date'
    )

# Show available sources
sources = SOURCES.NEWS_SOURCE
print('Available sources:')
for i, station in enumerate(sources.keys(), start=1):
    print(f"{i}. {station}")

# Pick source
fancy_speak('what news you wanna hear???', voice=EN_VOICE, async_play=True)
choice = input('\nChoose source (number or name): ').strip().lower()

# Resolve choice
if choice.isdigit():
    idx = int(choice) - 1
    keys = list(sources.keys())
    if 0 <= idx < len(keys):
        selected = {keys[idx]: sources[keys[idx]]}
    else:
        print('Invalid number.')
        exit()
elif choice in sources:
    selected = {choice: sources[choice]}
elif choice.title() in sources:
    selected = {choice.title(): sources[choice.title()]}
else:
    print('Invalid choice.')
    exit()

# How many articles
while True:
    try:
        fancy_speak('how many articles should i read?', voice=EN_VOICE, async_play=True)
        choice2 = int(input('> ').strip())
        break
    except ValueError:
        fancy_speak('wrong input', voice=EN_VOICE, async_play=True)

# Run feed
for station, source in selected.items():
    feed = feedparser.parse(source)
    print(f'----{station}----')

    for i, entry in enumerate(feed.entries[:choice2], start=1):
        title = getattr(entry, 'title', 'No title')
        summary = clean_html(getattr(entry, 'summary', ''))
        date = format_date(entry)

        print(f'{i}. {title}')
        print(summary)
        print(f'Date: {date}')
        print('')

        speak_text = f'{i}......{title}...{summary}'
        fancy_speak(speak_text, voice=get_voice(speak_text))

for i in selected.keys():
    outro = f'thats the latest news from {i}... hope youre informed'
    fancy_speak(outro, voice=get_voice(outro))