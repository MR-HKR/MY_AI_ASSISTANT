import subprocess

def RunBash(file, args=None, capture=False):
    if args is None:
        args = []

    if capture:
        result = subprocess.run(
            ['bash', file, *args],
            text=True,
            capture_output=True
        )
        return result.stdout.strip(), result.stderr.strip()

    else:
        process = subprocess.Popen(
            ['bash', file, *args]
        )
        return process
    