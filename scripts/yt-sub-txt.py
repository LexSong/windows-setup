#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = ["curl_cffi", "pysubs2", "yt-dlp"]
# ///
"""Download YouTube subtitles and convert them to plain text."""

import sys
import tempfile
from itertools import groupby
from pathlib import Path

import pysubs2
import yt_dlp


def parse_args(argv):
    """Split argv into (url, extra yt-dlp args, output path or None)."""
    # We take over yt-dlp's -o/--output for our own result. The value is a plain
    # path, not a yt-dlp template. "-" means stdout. We cannot use argparse here:
    # parse_known_args can mistake the value of an unknown yt-dlp option for the URL.
    args = list(argv)
    output = None
    i = 0
    while i < len(args):
        if args[i] in ("-o", "--output"):
            if i + 1 >= len(args):
                print(f"{args[i]} needs a value.", file=sys.stderr)
                sys.exit(1)
            output = args[i + 1]
            del args[i : i + 2]
        elif args[i].startswith("--output="):
            output = args[i].split("=", 1)[1]
            del args[i]
        else:
            i += 1

    if not args:
        print(
            "Usage: yt-sub-txt.py <video_url> [-o PATH|-] [extra yt-dlp args...]\n"
            "  -o PATH  write the text to PATH (a plain path, not a yt-dlp template)\n"
            "  -o -     write the text to stdout",
            file=sys.stderr,
        )
        sys.exit(1)

    return args[0], args[1:], output


def main():
    url, extra_args, output = parse_args(sys.argv[1:])

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
            # Keep stdout free for the transcript when -o - is used.
            logtostderr=True,
        )
        ydl_opts.setdefault("subtitleslangs", ["en"])

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # download() returns a non-zero code when yt-dlp hit an error
            # (network, bot check, private video). yt-dlp already printed it.
            if ydl.download(urls):
                print("yt-dlp failed; see errors above.", file=sys.stderr)
                sys.exit(1)

        srt_files = list(Path(tmp).glob("*.srt"))
        if not srt_files:
            print("No subtitles found for that video/language.", file=sys.stderr)
            sys.exit(1)
        srt_path = srt_files[0]

        subs = pysubs2.load(str(srt_path))
        texts = [event.plaintext.strip() for event in subs]
        # groupby collapses runs of repeated cues; drop the blanks that remain.
        lines = [text for text, _ in groupby(texts) if text]
        out_name = srt_path.stem + ".txt"

    text = "\n".join(lines)
    if output == "-":
        sys.stdout.reconfigure(encoding="utf-8")  # pyright: ignore[reportAttributeAccessIssue]
        print(text)
        return

    if output:
        out_path = Path(output)
    else:
        out_path = Path.cwd() / out_name
    out_path.write_text(text, encoding="utf-8")
    print(f"Saved: {out_path}")


if __name__ == "__main__":
    main()
