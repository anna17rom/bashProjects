#!/bin/bash
#dla wszystkich słów występujących w plikach w danym poddrzewie katalogów, drukuje statystyki ile razy dane słowo wystąpiło we wszystkich tych plikach.
if [ $# -eq 0 ]; then
    echo "Use: $0 <ścieżka_do_katalogu>"
    exit 1
fi

directory=$1


if [ ! -d "$directory" ]; then
    echo "$directory nie jest katalogiem."
    exit 1
fi
#zbieramy,zamieniamy spacje na nowe linie, aby każda oddzielona spacją jednostka tekstu była na nowej linii,sortyjemy,liczymy unikalne elementy 
find "$directory" -type f -exec cat {} + | tr -s ' ' '\n' | sort | uniq -c | sort -k2

