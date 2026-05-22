#!/usr/bin/env bash
#
# Send selected text to festival TTS.
#
# Dependencies: xsel, festival

xsel | festival --tts --pipe
