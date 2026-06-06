#!/usr/bin/python3

#!/usr/bin/python3
#
# Convert mp3/wav files to text files

import shutil
import signal
import sys
from pathlib import Path
from typing import Any, Literal

import click
import speech_recognition as sr
from pydub import AudioSegment
from pydub.silence import split_on_silence
from utilities.helpers import Notification

# Constants
MIN_SILENCE_LEN = 300
SILENCE_THRESH = -14
KEEP_SILENCE = 1000

# -- Create a speech recognition object
recognizer = sr.Recognizer()


def signal_handler(signum, frame) -> None:
    """Clean up working directory"""

    print("🛑 Script canceled. Cleaning up working dir")
    delete_working_dir()


def delete_working_dir() -> None:
    """Delete temporary directory"""
    working_dir = Path.cwd().joinpath("audio-chunks")
    if working_dir.exists():
        shutil.rmtree(working_dir)
        sys.exit(1)


# -- Attach the signal to signal_handler
signal.signal(signal.SIGINT, signal_handler)


def create_working_dir() -> Path:
    """Create temporary directory to store audio chunks and transcriptions"""

    folder_name: Literal["audio-chunks"] = "audio-chunks"
    working_dir = Path.cwd().joinpath(folder_name)

    if working_dir.is_dir():
        delete_working_dir()
    elif not working_dir.is_dir():
        working_dir.mkdir(exist_ok=True)
        print(f"👌 Created temporary folder: {working_dir}")
    return working_dir


@click.command()
@click.argument("filename", required=True)
@click.option(
    "-l",
    "--language",
    type=click.Choice(["es", "us"]),
    help="Language to transcribe to",
)
def get_large_audio_transcription(filename: str, language=False) -> None:
    """
    Split the audio file into chunks and apply speech recognition on each
    of these chunks if the audio file is a WAVE file. If the audio file is MP3
    process the whole audio file in a single chunk.
    """
    working_dir = create_working_dir()
    sound_track = sound_from_file(filename)

    # -- Split audio sound where silence is 1000 milliseconds or more and get chunks
    audio_chunks = make_chunks(sound_track)

    full_transcription = ""

    # -- Process each chunk
    for i, audio in enumerate(audio_chunks, start=1):
        # -- Export audio chunks and save it in the `folder_name` directory.
        audio_filename = working_dir.joinpath(f"{filename}{-i}.wav")
        audio.export(audio_filename, format="wav")

        # -- Recognize the chunk
        with sr.AudioFile(str(audio_filename)) as source:
            audio_listened = recognizer.record(source)
            # -- Try converting it to text
            try:
                if language:
                    partial_text = recognizer.recognize_google(
                        audio_listened, language="es-ES"
                    )
                else:
                    partial_text = recognizer.recognize_google(audio_listened)

            except sr.UnknownValueError:
                print(
                    f"\n⚠️  Skipping unrecognized audio chunk: {audio_filename.stem}\n"
                )
            else:
                partial_text = (
                    partial_text.capitalize()
                )  # Capitalize only the first letter
                full_transcription += f"{partial_text}. "
                write_chunk_file(audio_filename, partial_text)
            write_full_file(full_transcription, working_dir)

    notifyme = Notification()
    notifyme.send_message(title="Finished", message="Audio converted to text")


def write_chunk_file(audio_filename: Path, partial_text: Any) -> None:
    """Write the partial_text of a chunk file"""

    file = audio_filename.rename(audio_filename.with_suffix(".txt"))
    print(f"🔨 Converting {audio_filename.stem} to {audio_filename.stem}.txt")

    with open(file, "w") as audio_file:
        audio_file.write(partial_text)


def write_full_file(full_text: Any, working_dir: Path) -> None:
    """Write the full transcription"""

    working_dir = working_dir.joinpath("full_transcription.txt")

    with open(working_dir, "w") as audio_file:
        _write_transcription(audio_file, full_text)
        print("🍻 Audio file converted to text 🍻\n")


def _write_transcription(audio_file, formatted_text):
    """Write the text to a file"""
    audio_file.write("--- Begin of transcription ---")
    audio_file.write("\n")
    audio_file.write(formatted_text)
    formatted_text.rstrip(".")
    audio_file.write("\n")
    audio_file.write("--- End of transcription  ---")


def sound_from_file(filename: str) -> AudioSegment:
    """Convert the audio file"""

    cwd = Path.cwd()
    if cwd.joinpath(filename).exists():
        if filename.endswith("wav"):
            audio_segment = AudioSegment.from_wav(filename)
        elif filename.endswith("mp3"):
            audio_segment = AudioSegment.from_mp3(filename)
            audio_segment.export(filename, format="wav", bitrate="192k")
        else:
            signal.signal(signal.SIGINT, signal_handler)
            raise ValueError(f"[!] Invalid file type: {filename}")
    else:
        signal.signal(signal.SIGINT, signal_handler)
        raise FileNotFoundError(f"[!] File not found: {filename}")

    print(f"📂 Opening {filename}")

    return audio_segment


def make_chunks(sound_track) -> list:
    """Split the audio file on silent sections"""

    print("⏳ Processing audio. This will take time ...\n")
    return split_on_silence(
        sound_track,
        # -- The minimum length of silent sections in milliseconds
        min_silence_len=MIN_SILENCE_LEN,
        # -- Default -16
        silence_thresh=SILENCE_THRESH,
        # -- How much silence to keep in ms
        keep_silence=KEEP_SILENCE,
    )


if __name__ == "__main__":
    get_large_audio_transcription()
