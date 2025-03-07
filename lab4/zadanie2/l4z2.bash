#!/bin/bash

# Sprawdzenie liczby argumentów
if [ "$#" -ne 3 ]; then
    echo "Użycie: $0 <revision_start> <revision_end> <svn_url>"
    exit 1
fi

# Pobranie argumentów
REVISION_START=$1
REVISION_END=$2
SVN_URL=$3

# Sprawdzenie, czy REVISION_START i REVISION_END są liczbami
if ! [[ "$REVISION_START" =~ ^[0-9]+$ ]] || ! [[ "$REVISION_END" =~ ^[0-9]+$ ]]; then
    echo "Błąd: revision_start i revision_end muszą być liczbami."
    exit 1
fi

# Sprawdzenie poprawności numerów rewizji
if [ "$REVISION_START" -gt "$REVISION_END" ]; then
    echo "Błąd: revision_start musi być mniejszy lub równy revision_end"
    exit 1
fi

# Utworzenie lokalnego katalogu dla SVN
TEMP_DIR="svn_temp"
REPO_NAME=$(basename "$SVN_URL")
GIT_REPO="$REPO_NAME"

# Czyszczenie poprzednich danych
rm -rf "$TEMP_DIR" "$GIT_REPO"

# Tworzenie pustego repozytorium GIT z określoną nazwą gałęzi (np. main)
git init -b main "$GIT_REPO" || { echo "Błąd: Nie udało się zainicjalizować repozytorium Git"; exit 1; }

# Klonowanie repozytorium SVN w podanym zakresie rewizji, zaczynając od REVISION_START
svn checkout -r "$REVISION_START" "$SVN_URL" "$TEMP_DIR"
if [ $? -ne 0 ]; then
    echo "Błąd: Nie udało się sklonować repozytorium SVN do rewizji $REVISION_START"
    exit 1
fi

cd "$TEMP_DIR" || { echo "Błąd: Nie udało się wejść do katalogu $TEMP_DIR"; exit 1; }

# Iterowanie po rewizjach i kopiowanie zmian do GIT
for ((REV="$REVISION_START"; REV<="$REVISION_END"; REV++)); do
    echo "Przetwarzanie rewizji: $REV"

    # Aktualizacja do kolejnej rewizji (jeśli to nie jest pierwsza)
    if [ "$REV" -ne "$REVISION_START" ]; then
        svn update -r "$REV" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Błąd: Nie udało się zaktualizować do rewizji $REV"
            exit 1
        fi
    fi

    # Kopiowanie stanu katalogu do repozytorium GIT, pomijając pliki .git, .svn, .gitignore
    rsync -a --delete --exclude='.git' --exclude='.svn' --exclude='.gitignore' ./ "../$GIT_REPO/"
    if [ $? -ne 0 ]; then
        echo "Błąd: Nie udało się zsynchronizować plików dla rewizji $REV"
        exit 1
    fi

    # Pobranie logu z SVN
    LOG_MESSAGE=$(svn log -r "$REV" --quiet | sed -n '/^$/,$p' | sed '1d;$d')
    if [ -z "$LOG_MESSAGE" ]; then
        LOG_MESSAGE="Brak wiadomości logu dla rewizji $REV"
    fi

    # Commit do GIT tylko jeśli są zmiany
    cd "../$GIT_REPO" || { echo "Błąd: Nie udało się wejść do katalogu $GIT_REPO"; exit 1; }
    git add -A

    # Sprawdzenie, czy są zmiany do commitowania
    if ! git diff --cached --quiet; then
        git commit -m "Rewizja $REV: $LOG_MESSAGE" && echo "Commit dla rewizji $REV został dodany."
    else
        echo "Brak zmian do commitowania dla rewizji $REV."
    fi

    if [ $? -ne 0 ]; then
        echo "Błąd: Nie udało się dodać commita dla rewizji $REV"
        exit 1
    fi

    cd "../$TEMP_DIR" || { echo "Błąd: Nie udało się wrócić do katalogu $TEMP_DIR"; exit 1; }
done

# Czyszczenie tymczasowego katalogu SVN
cd ..
rm -rf "$TEMP_DIR"

echo "Repozytorium GIT zostało utworzone w katalogu $GIT_REPO"



















