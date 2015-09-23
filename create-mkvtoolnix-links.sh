#!/bin/bash

BIN_TARGET='/usr/local/bin'
MAN_TARGET='/usr/local/share/man/man1'

MKV_BINARIES=( \
	mkvextract \
	mkvinfo \
	mkvmerge \
	mkvpropedit \
)


# Find MKVToolNix app

CHECK_FOR=${MKV_BINARIES[0]}

FOUND_APP=$(find /Applications ~/Applications \
	-maxdepth 1 \
	-type d \
	-name 'MKVToolNix*.app' \
	-exec [ -e "{}"'/Contents/MacOS/'"$CHECK_FOR" ] \; \
	-exec echo "{}" \; \
	-quit)

if [[ -z "$FOUND_APP" ]] ; then
	echo 'Error: MKVToolNix application not found'
	exit 1
fi

MANS_BASE="$FOUND_APP"'/Contents/MacOS/man/'


# Create links to binaries

for (( i=0; i<${#MKV_BINARIES[*]}; i++ )) ; do
	BIN="$FOUND_APP"'/Contents/MacOS/'"${MKV_BINARIES[$i]}"
	ln -fs "$BIN" "$BIN_TARGET"
done


# Guess system language

SYS_LC="$LC_MESSAGES"

if [ -z "$SYS_LC" ] ; then
	SYS_LC="$LC_ALL"
fi


# Select mans dir by language

if [ ! -z "$SYS_LC" ] ; then
	LANG="${SYS_LC%%\.*}"

	if [ -d "${MANS_BASE}/$LANG" ] ; then
		MANS_LANG_DIR="$LANG"
	else 
		LANG="${SYS_LC%%_*}"

		if [ -d "${MANS_BASE}/$LANG" ] ; then
			MANS_LANG_DIR="$LANG"
		fi
	fi
fi


# Create links to mans
MANS_SRC=$(echo -n "$MANS_BASE"'/'"$MANS_LANG_DIR"'/man1' \
	| sed -E 's/\/+/\//g')
find "$MANS_SRC" \
	-maxdepth 1 \
	-name '*.1' \
	-exec ln -fs "{}" "$MAN_TARGET" \;
