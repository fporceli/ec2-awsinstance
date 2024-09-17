#!/bin/bash

# Ler o input do usuário
read -p "Digite um número entre 1 e 4: " numero

# Verificar se o número está fora do intervalo de 1 a 4
if [ $numero -lt 1 ] || [ $numero -gt 4 ]; then
    echo "Você não digitou um número entre 1 e 4."
    # Ação a ser tomada quando o número não está entre 1 e 4
else
    echo "Você digitou o número correto: $numero"
fi

