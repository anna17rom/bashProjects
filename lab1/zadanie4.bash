#!/bin/bash
#który dla każdego słowa pojawiającego się w plikach danego poddrzewa katalogów, drukuje linie, w których to słowo występuje, poprzedzonenazwą pliku, z którego pochodzą.
if [ $# -eq 0 ]; then
    echo "Use: $0 <ścieżka_do_katalogu>"
    exit 1
fi


directory=$1


find "$directory" -type f | while read file; do
    while read -r line; do
        for word in $line; do
            grep -H -n "\b$word\b" "$file" | while read -r result; do
                echo "$word:$result"
            done
        done
    done < "$file"
done | sort -t: -k1,1 | uniq | awk -F':' '
{
    word = $1
    if (prev_word != word) {
        print ""
        print word ":"
        prev_word = word
    }
    print $2 ":" $3 ":" $4
}'

