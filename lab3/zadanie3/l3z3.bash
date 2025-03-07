#!/bin/bash

# Sprawdzamy, czy podano odpowiednią liczbę argumentów
if [ "$#" -ne 2 ]; then
    echo "Użycie: $0 <nr_rewizji> <URL_katalogu>"
    exit 1
fi

# Pobieramy argumenty
revision=$1
url=$2

# Tymczasowy katalog do pobierania plików SVN
temp_dir=$(mktemp -d)

# Pobieramy wszystkie pliki tekstowe z poddrzewa SVN w danej rewizji
svn export -r "$revision" "$url" "$temp_dir" --force

# Analizujemy pliki, aby policzyć liczbę plików, w których występuje każde słowo
find "$temp_dir" -type f | while read -r file; do
    # Zamieniamy spacje na nowe linie, sortujemy i usuwamy duplikaty w obrębie pliku
    tr -s ' ' '\n' < "$file" | sort -u
done | sort | uniq -c | sort -k2 | awk '{print $2 ": " $1}'

# Usuwamy katalog tymczasowy
rm -rf "$temp_dir"

