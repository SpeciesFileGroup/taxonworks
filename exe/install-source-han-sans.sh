#!/bin/bash
set -e
set -x

# Installs the Source Han Sans CJK font for Prawn PDF generation
# (see lib/vendor/prawn.rb). Not vendored in the repo - it's ~34MB.
# Only present in images built from this base image (production/staging);
# local dev and CI don't have it, and Vendor::Prawn degrades gracefully
# when it's absent (CJK fallback simply unavailable, Latin/Cyrillic/Greek
# diacritics via LiberationSans still work).

VERSION=v2.002.1
ARCHIVE=source-han-sans-ttf-2.002.1.7z
SHA256=b3057c0d4df53bbd96d292e69b9393efbe9b3f5b7a7354f2ec00b91535ed7636
DEST=/usr/local/share/fonts/source-han-sans

mkdir -p "$DEST"
cd /tmp

curl -sL -o "$ARCHIVE" "https://github.com/be5invis/source-han-sans-ttf/releases/download/$VERSION/$ARCHIVE"
echo "$SHA256  $ARCHIVE" | sha256sum -c -

# Archive contains every weight x region combination; we only need the
# Regular weight, default (Japanese-priority) region build.
7z e "$ARCHIVE" SourceHanSans-Regular.ttf -o"$DEST" -y

curl -sL -o "$DEST/LICENSE" "https://raw.githubusercontent.com/be5invis/source-han-sans-ttf/master/LICENSE"

rm "$ARCHIVE"
