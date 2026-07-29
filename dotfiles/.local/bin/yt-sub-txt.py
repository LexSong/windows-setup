#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = ["pysubs2", "yt-dlp"]
# ///
"""Download YouTube subtitles and convert them to plain text."""

import sys
import tempfile
from pathlib import Path

import pysubs2
import yt_dlp


def iter_texts(subs: pysubs2.SSAFile):
    for event in subs:
        yield event.plaintext.strip()


def dedupe_lines(texts) -> list:
    lines = []
    prev = None
    for text in texts:
        if text and text != prev:
            lines.append(text)
        prev = text
    return lines


def main():
    if len(sys.argv) < 2:
        print("Usage: yt-sub-txt.py <video_url> [extra yt-dlp args...]")
        sys.exit(1)

    url = sys.argv[1]
    extra_args = sys.argv[2:]

    with tempfile.TemporaryDirectory() as tmp:
        outtmpl = str(Path(tmp) / "%(title)s.%(ext)s")

        # parse_options() only loads yt-dlp's config files (portable/home/user/system)
        # when called with no argv, so stage our args via sys.argv instead of passing
        # them directly. Always restore sys.argv after, even if parse_options() raises.
        old_argv = sys.argv
        sys.argv = ["yt-dlp", *extra_args, "-o", outtmpl, url]
        try:
            _, _, urls, ydl_opts = yt_dlp.parse_options()
        finally:
            sys.argv = old_argv

        ydl_opts.update(
            skip_download=True,  # pyright: ignore[reportArgumentType]
            writesubtitles=True,
            writeautomaticsub=True,
            subtitlesformat="srt",
        )
        ydl_opts.setdefault("subtitleslangs", ["en"])

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download(urls)

        srt_files = list(Path(tmp).glob("*.srt"))
        if not srt_files:
            print("No subtitles found for that video/language.")
            sys.exit(1)
        srt_path = srt_files[0]

        subs = pysubs2.load(str(srt_path))
        lines = dedupe_lines(iter_texts(subs))
        out_name = srt_path.stem + ".txt"

    out_path = Path.cwd() / out_name
    out_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Saved: {out_path}")


if __name__ == "__main__":
    main()
