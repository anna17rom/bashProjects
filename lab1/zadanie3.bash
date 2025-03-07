#!/bin/bash
#dla każdego słowa pojawiającego się w plikach danego poddrzewa katalogów, drukuje liczbę plików, w których to słowo występuje.
if [ $# -eq 0 ]; then
    echo "Use: $0 <ścieżka_do_katalogu>"
    exit 1
fi

directory=$1

if [ ! -d "$directory" ]; then
    echo "$directory nie jest katalogiem."
    exit 1
fi
#sortuje słowa alfabetycznie i usuwa zduplikowane wystąpienia w obrębie każdego pliku.
find "$directory" -type f | while read file; do
    tr -s ' ' '\n' < "$file" | sort -u
done | sort | uniq -c | sort -k2 | awk '{print $2 ": " $1}'

