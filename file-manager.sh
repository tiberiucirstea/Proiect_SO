#!/bin/bash

ROSU='\033[0;31m'
RESET='\033[0m'

INDEX="index.txt"

if [ ! -f "$INDEX" ]; then
    touch "$INDEX"
fi

intrebare_yn() {
    local mesaj="$1"
    local raspuns
    
    while true; do
        echo -n "$mesaj (Y/N): "
        read raspuns
        
        if [[ "$raspuns" == "Y" || "$raspuns" == "y" ]]; then
            return 0
        elif [[ "$raspuns" == "N" || "$raspuns" == "n" ]]; then
            return 1
        else
            echo -e "\n${ROSU}EROARE${RESET} Optiune nevalida. Introdu Y sau N.\n"
        fi
    done
}

revenire_meniu() {
    echo -en "\nApasa orice tasta pentru a reveni la meniul principal..."
    read -s -n1 tasta
    clear
    return
}

adaugare_fisiere() {

    echo -e "\n=== ADAUGARE FISIERE ===\n"
    
    while true; do
        while true; do
            echo -n "Calea completa a fisierului: "
            read cale
            
            if [[ -z "$cale" || "$cale" != /* ]]; then
                echo -e "${ROSU}EROARE${RESET} Calea introdusa este nevalida. Incearca din nou.\n"
                continue
            fi

            if [ -d "$cale" ]; then
                echo -e "${ROSU}EROARE${RESET} Nu se pot inregistra directoare. Incearca din nou.\n"
                continue
            fi

            if [ ! -f "$cale" ]; then
                echo -e "${ROSU}EROARE${RESET} Fisierul nu exista la calea indicata. Incearca din nou.\n"
                continue
            fi

            nume=$(basename "$cale")

            if grep -q "^$nume|" "$INDEX"; then
                echo -e "${ROSU}EROARE${RESET} Fisierul \"$nume\" este deja inregistrat.\n"
                
                if intrebare_yn "Doresti sa adaugi alt fisier?"; then
                    clear
                    echo -e "\n=== ADAUGARE FISIERE ===\n"
                    continue 2
                else
                    revenire_meniu
                    return
                fi
            fi

            break
        done

        while true; do
            echo -n "Descriere: "
            read descriere

            if [ -z "$descriere" ]; then
                echo -e "${ROSU}EROARE${RESET} Descrierea nu poate fi vida.\n"
                continue
            elif ! [[ "$descriere" =~ ^[a-zA-Z0-9_]+$ ]]; then
                echo -e "${ROSU}EROARE${RESET} Descrierea poate contine doar litere, cifre si caracterul underscore (_).\n"
                continue
            else
                break
            fi
        done

        while true; do
            echo -n "Categorie: "
            read categorie

            if [ -z "$categorie" ]; then
                echo -e "${ROSU}EROARE${RESET} Categoria nu poate fi vida.\n"
                continue
            elif ! [[ "$categorie" =~ ^[a-zA-Z0-9_]+$ ]]; then
                echo -e "${ROSU}EROARE${RESET} Categoria poate contine doar litere, cifre si caracterul underscore (_).\n"
                continue
            else
                break
            fi
        done

        data_adaugare=$(date "+%d-%m-%Y")

        echo "$nume|$cale|$descriere|$categorie|$data_adaugare" >>"$INDEX"
        echo -e "\nFisierul \"$nume\" a fost adaugat cu succes."

        if intrebare_yn "Doresti sa adaugi un alt fisier?"; then
            clear
            echo -e "\n=== ADAUGARE FISIERE ===\n"
            continue
        else
            revenire_meniu
            return
        fi
    done
}

listare_fisiere() {
    echo -e "\n=== LISTARE FISIERE ===\n"
    
    if [ ! -s "$INDEX" ]; then
        echo -e "${ROSU}EROARE${RESET} Nu exista fisiere inregistrate."
        revenire_meniu
        return
    fi

    while true; do
        if intrebare_yn "Doresti sa listezi doar fisierele dintr-o anumita categorie?"; then
            echo -n "Categorie: "
            read categorie

            rezultate=$(grep -i ".*|.*|.*|$categorie|" "$INDEX")
            if [ -z "$rezultate" ]; then
                echo -e "${ROSU}EROARE${RESET} Nu exista fisiere in aceasta categorie."
                
                if intrebare_yn "Doresti sa listezi alte fisiere?"; then
                    clear
                    echo -e "\n=== LISTARE FISIERE ===\n"
                    continue
                else
                    revenire_meniu
                    return
                fi
            else
                echo ""
                antet="Nr. crt.|Nume|Cale|Descriere|Categorie|Data adaugarii"
                {
                    echo "$antet"
                    echo "$rezultate" | nl -w2 -s"|"
                } | column -t -s '|'

                echo -e "\nListarea fisierelor s-a realizat cu succes."
                
                if intrebare_yn "Doresti sa listezi alte fisiere?"; then
                    clear
                    echo -e "\n=== LISTARE FISIERE ===\n"
                    continue
                else
                    revenire_meniu
                    return
                fi
            fi
        else
            echo ""
            antet="Nr. crt.|Nume|Cale|Descriere|Categorie|Data adaugarii"
            {
                echo "$antet"
                cat "$INDEX" | nl -w2 -s"|"
            } | column -t -s '|'

            echo -e "\nListarea fisierelor s-a realizat cu succes."
            
            if intrebare_yn "Doresti sa listezi alte fisiere?"; then
                clear
                echo -e "\n=== LISTARE FISIERE ===\n"
                continue
            else
                revenire_meniu
                return
            fi
        fi
    done
}

cautare_fisiere() {
    echo -e "\n=== CAUTARE FISIERE ===\n"
    
    if [ ! -s "$INDEX" ]; then
        echo -e "${ROSU}EROARE${RESET} Nu exista fisiere inregistrate."
        revenire_meniu
        return
    fi

    while true; do
        while true; do
            echo -n "Cuvant cheie (nume sau descriere) pentru cautare (min. 3 caractere): "
            read cuvant

            if [[ -z "$cuvant" || ${#cuvant} -lt 3 ]]; then
                echo -e "${ROSU}EROARE${RESET} Introdu cel putin 3 caractere pentru cautare.\n"
                continue
            fi

            break
        done

        rezultate=$(awk -F"|" -v termen="$cuvant" '
            index(tolower($1), tolower(termen)) > 0 ||
            index(tolower($3), tolower(termen)) > 0
        ' "$INDEX")

        if [ -z "$rezultate" ]; then
            echo -e "${ROSU}EROARE${RESET} Nu s-au gasit fisiere care sa corespunda cu '$cuvant'.\n"
            
            echo ""
            if intrebare_yn "Doresti sa efectuezi o alta cautare?"; then
                clear
                echo -e "\n=== CAUTARE FISIERE ===\n"
                continue
            else
                revenire_meniu
                return
            fi
        else
            numar_rezultate=$(echo "$rezultate" | wc -l)
            echo -e "\nS-au gasit $numar_rezultate rezultate pentru '$cuvant':"
            echo ""
            antet="Nr. crt.|Nume|Cale|Descriere|Categorie|Data adaugarii"
            {
                echo "$antet"
                echo "$rezultate" | nl -w2 -s"|"
            } | column -t -s '|'
            
            echo ""
            if intrebare_yn "Doresti sa efectuezi o alta cautare?"; then
                clear
                echo -e "\n=== CAUTARE FISIERE ===\n"
                continue
            else
                revenire_meniu
                return
            fi
        fi
    done
}

stergere_fisiere() {
    echo -e "\n=== STERGERE FISIERE ===\n"
    
    if [ ! -s "$INDEX" ]; then
        echo -e "${ROSU}EROARE${RESET} Nu exista fisiere inregistrate."
        revenire_meniu
        return
    fi

    while true; do
        echo -n "Numele fisierului pe care vrei sa il stergi: "
        read nume_sters

        if [ -z "$nume_sters" ]; then
            echo -e "${ROSU}EROARE${RESET} Nu ai introdus niciun nume de fisier.\n"
            continue
        fi

        if grep -q "^${nume_sters}|" "$INDEX"; then
            if intrebare_yn "Esti sigur ca vrei sa stergi fisierul \"$nume_sters\"?"; then
                grep -v "^${nume_sters}|" "$INDEX" > temp.txt && mv temp.txt "$INDEX"
                echo -e "\nFisierul \"$nume_sters\" a fost sters cu succes."

                if intrebare_yn "Doresti sa stergi alt fisier?"; then
                    clear
                    echo -e "\n=== STERGERE FISIERE ===\n"
                    continue
                else
                    revenire_meniu
                    return
                fi
            else
                echo -e "\nOperatiunea a fost anulata."

                if intrebare_yn "Doresti sa stergi alt fisier?"; then
                    clear
                    echo -e "\n=== STERGERE FISIERE ===\n"
                    continue
                else
                    revenire_meniu
                    return
                fi
            fi
        else
            echo -e "${ROSU}EROARE${RESET} Fisierul \"$nume_sters\" nu a fost gasit.\n"
            
            if intrebare_yn "Doresti sa stergi alt fisier?"; then
                clear
                echo -e "\n=== STERGERE FISIERE ===\n"
                continue
            else
                revenire_meniu
                return
            fi
        fi
    done
}

meniu() {
    clear
    while true; do
        echo -e "\n=== MENIU ==="
        echo "1. Adaugare fisiere"
        echo "2. Listare fisiere"
        echo "3. Cautare fisiere"
        echo "4. Stergere fisiere"
        echo "5. Iesire"
        echo -en "\nAlege optiunea: "
        read opt
        clear

        case "$opt" in
        1) adaugare_fisiere ;;
        2) listare_fisiere ;;
        3) cautare_fisiere ;;
        4) stergere_fisiere ;;
        5) break ;;
        *) echo -e "${ROSU}EROARE${RESET} Optiune nevalida. Incearca din nou.\n" ;;
        esac
    done
}

meniu
