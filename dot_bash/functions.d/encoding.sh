#!/bin/bash

# URL Encoding/Decoding functions
# Requires: nkf (Network Kanji Filter)

# URL encode a string
url_encode() {
    if ! command -v nkf >/dev/null 2>&1; then
        echo "Error: nkf command not found" >&2
        return 1
    fi
    echo "$1" | nkf -WwMQ | sed 's/=$//g' | tr = % | tr -d '\n'
}

# URL decode a string
url_decode() {
    if ! command -v nkf >/dev/null 2>&1; then
        echo "Error: nkf command not found" >&2
        return 1
    fi
    echo "$1" | tr % = | nkf -WwmQ
}

# Unicode Encoding/Decoding functions
# Requires: nkf, xxd

# Encode string to unicode escape sequences
unicode_encode() {
    if ! command -v nkf >/dev/null 2>&1 || ! command -v xxd >/dev/null 2>&1; then
        echo "Error: nkf or xxd command not found" >&2
        return 1
    fi
    echo -en "$1" | nkf -W -w32B0 | xxd -ps -c4 | sed 's/^0\{4\}//' | xargs printf '\\u%4s'
}

# Decode unicode escape sequences
unicode_decode() {
    echo -en "$1"
}