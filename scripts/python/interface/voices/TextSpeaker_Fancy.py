from edge_tts import Communicate

import asyncio

import io

from scripts.python.helpers.BashRunner import RunBash

async def _generate_audio(text, voice):
    tts = Communicate(text, voice=voice)
    audio_bytes = io.BytesIO()
    async for chunk in tts.stream():
        if chunk['type'] == 'audio':
            audio_bytes.write(chunk['data'])
    audio_bytes.seek(0)
    return audio_bytes.read()

def fancy_speak(text, voice='en-US-JennyNeural', async_play=False):
    audio_data = asyncio.run(_generate_audio(text, voice))
    tmp_path = '/tmp/tts_output.mp3'
    with open(tmp_path, 'wb') as f:
        f.write(audio_data)
    script = '/tmp/tts_play.sh'
    with open(script, 'w') as f:
        f.write(f'mpv --no-terminal \'{tmp_path}\'\n')
    if async_play:
        RunBash(script)
    else:
        proc = RunBash(script)
        proc.wait()
