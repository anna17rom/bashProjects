#!/bin/bash
#drukuje słowa występujące więcej niż raz w jakimś wierszu, wraz z tymi wierszami i nazwami plików, z których te wiersze pochodzą
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
#zwraca każdą linię pliku, poprzedzoną numerem linii.
    grep -n '' "$file" | while IFS=: read -r nr_line line; do
        words=$(echo "$line" | tr -s ' ' '\n' | sort)
        duplicates=$(echo "$words" | uniq -d)
        
        if [ -n "$duplicates" ]; then
            for word in $duplicates; do
                echo "$word:"
                echo "$file:$lnr_line:$line"
            done
        fi
    done
done

