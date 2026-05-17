import feedparser

from html import unescape

import re

from scripts.python.interface.voices.TextSpeaker_Fancy import fancy_speak

from storage.config.sources import SOURCES

def clean_html(text):
    text = re.sub(r'<[^>]+>', '', text)
    return unescape(text).strip()

# Show available sources
sources = SOURCES.NEWS_SOURCE
print("Available sources:")
for i, station in enumerate(sources.keys(), start=1):
    print(f"{i}. {station}")

# Pick
fancy_speak('what news you wanna hear???',async_play=True)
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
else:
    print('Invalid choice.')
    exit()


# Run
for station, source in selected.items():
    feed = feedparser.parse(source)
    print(f'----{station}----')
    for i, entry in enumerate(feed.entries[:3], start=1):
        print(f'{i}. {entry.title}')
        print(clean_html(entry.summary))
        print('')
        fancy_speak(f'{i}......{entry.title}...{clean_html(entry.summary)}')

for i in selected.keys():
    fancy_speak(f'thats the latest news from {i}... hope youre informed')


