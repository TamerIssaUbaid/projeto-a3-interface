#!/bin/bash

# Projeto A3 - GUI com Zenity (corrigido)
# Támer Issa Ubaid e equipe - 01/06/2025

while true; do
    opcao=$(zenity --list \
        --title="Menu Principal" \
        --column="Opção" --column="Descrição" \
        1 "Contar arquivos com string no nome" \
        2 "Cadastrar novo usuário" \
        3 "Buscar usuários por string" \
        4 "Buscar grupos por string" \
        5 "Verificar IP na rede" \
        6 "Exibir informações do sistema" \
        7 "Detalhes de um arquivo" \
        8 "Total de usuários e grupos" \
        9 "Funcionalidade livre 1" \
        10 "Funcionalidade livre 2" \
        11 "Sair" \
        --height=500 --width=400)

    [ $? -ne 0 ] && break

    case $opcao in
        1)
            dir=$(zenity --entry --title="Diretório" --text="Digite o caminho do diretório:")
            str=$(zenity --entry --title="String" --text="Digite a string a buscar:")
            if [ -d "$dir" ]; then
                count=$(find "$dir" -type f -name "*$str*" | wc -l)
                zenity --info --text="Arquivos encontrados: $count"
            else
                zenity --error --text="Diretório inválido."
            fi
            ;;

        2)
            usuario=$(zenity --entry --title="Novo Usuário" --text="Digite o nome do novo usuário:")
            if id "$usuario" &>/dev/null; then
                zenity --warning --text="Usuário já existe."
            else
                sudo useradd "$usuario" && zenity --info --text="Usuário $usuario criado com sucesso."
            fi
            ;;

        3)
            str=$(zenity --entry --title="Buscar Usuários" --text="Digite a string para buscar:")
            count=$(cut -d: -f1 /etc/passwd | grep "$str" | wc -l)
            zenity --info --text="Usuários encontrados: $count"
            ;;

        4)
            str=$(zenity --entry --title="Buscar Grupos" --text="Digite a string para buscar:")
            count=$(cut -d: -f1 /etc/group | grep "$str" | wc -l)
            zenity --info --text="Grupos encontrados: $count"
            ;;

        5)
            ip=$(zenity --entry --title="Verificar IP" --text="Digite o IP para verificar:")
            if ping -c 1 "$ip" &>/dev/null; then
                zenity --info --text="IP ativo."
            else
                zenity --error --text="IP inativo."
            fi
            ;;

        6)
            memoria=$(free -h | grep Mem | awk '{print $4}')
            cpu=$(lscpu | grep "Model name" | sed 's/Model name:[ \t]*//')
            disco=$(df -h / | tail -1 | awk '{print $4}')
            zenity --info --title="Informações do Sistema" --text="Memória livre: $memoria\nCPU: $cpu\nDisco livre: $disco"
            ;;

        7)
            arq=$(zenity --file-selection --title="Selecione um arquivo")
            if [ -f "$arq" ]; then
                info=$(ls -lh "$arq")
                zenity --info --text="$info"
            else
                zenity --error --text="Arquivo não encontrado."
            fi
            ;;

        8)
            u_total=$(cut -d: -f1 /etc/passwd | wc -l)
            g_total=$(cut -d: -f1 /etc/group | wc -l)
            zenity --info --text="Total de usuários: $u_total\nTotal de grupos: $g_total"
            ;;

        9)
            tmpfile=$(mktemp)
            cat /etc/passwd > "$tmpfile"
            zenity --text-info --title="Todos os usuários" --width=600 --height=400 --filename="$tmpfile"
            rm "$tmpfile"
            ;;

        10)
            tmpfile=$(mktemp)

            echo "Usuários com senha VAZIA:" > "$tmpfile"
            awk -F: 'length($2)==0 { print " - " $1 }' /etc/shadow >> "$tmpfile"
            if ! grep -q " - " "$tmpfile"; then
                echo " - Nenhum usuário com senha vazia encontrado." >> "$tmpfile"
            fi

            echo -e "\nUsuários com senha BLOQUEADA:" >> "$tmpfile"
            awk -F: '$2 ~ /^[!*]/ { print " - " $1 }' /etc/shadow >> "$tmpfile"
            if ! grep -q " - " <(awk -F: '$2 ~ /^[!*]/' /etc/shadow); then
                echo " - Nenhum usuário com senha bloqueada encontrado." >> "$tmpfile"
            fi

            zenity --text-info --title="Senhas Vazias/Bloqueadas" --width=600 --height=400 --filename="$tmpfile"
            rm "$tmpfile"
            ;;

        11)
            zenity --info --text="Saindo do sistema. Até mais!"
            break
            ;;

        *)
            zenity --error --text="Opção inválida."
            ;;
    esac
done
