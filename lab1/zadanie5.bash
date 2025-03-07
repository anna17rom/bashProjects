#!/bin/bash
#zastępuje wszystkie wystąpienia znaku 'a' znakiem 'A'.
if [ $# -eq 0 ]; then
    echo "Use: $0 <ścieżka_do_katalogu>"
    exit 1
fi

directory=$1

if [ ! -d "$directory" ]; then
    echo "$directory nie jest katalogiem."
    exit 1
fi

find "$directory" -type f | while read file; do
    sed -i 's/a/A/g' "$file"
done

