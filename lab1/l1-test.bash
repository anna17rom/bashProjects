#!/bin/bash
for x in './zadanie'{{2..4},6,5,2}'.bash ./a';
do
    echo $'\n### ' ${x} $'###\n';
    ${x} ; # uruchomienie skryptu
done
