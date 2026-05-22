#!/bin/bash

edge-tts --voice "ru-RU-DmitryNeural" --text "$1" | mpv --no-terminal -
    