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

# Zamieniamy spacje na nowe linie, sortujemy i liczymy wystąpienia unikalnych słów
find "$temp_dir" -type f -exec cat {} + | tr -s ' ' '\n' | sort | uniq -c | sort -k2

# Usuwamy katalog tymczasowy
rm -rf "$temp_dir"

