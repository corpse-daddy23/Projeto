#!/bin/bash

SENHAS_ARQUIVO="senhas.txt"
CHAVE_MESTRA="chave_secreta"

#Caso nao tenha selecionado nenhum input ele dará este menu
mostrar_ajuda() {
  echo "Gestor de Senhas"
  echo "Uso: $0 [OPÇÃO]"
  echo "Opções:"
  echo "  -a, --adicionar     Adicionar uma nova senha"
  echo "  -r, --remover       Remover uma senha existente"
  echo "  -u, --atualizar     Atualizar uma senha existente"
  echo "  -l, --listar        Listar todas as senhas"
  echo "  -g, --gerar         Gerar uma senha aleatória"
  echo "  -h, --ajuda         Exibir esta mensagem de ajuda"
  exit 0
}

encriptar() {
  echo "$1" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$CHAVE_MESTRA"   #-aes-256-cbc nao funciona esta encriptação -> Meti a dar
}

desencriptar() {
  echo "$1" | openssl enc -aes-256-cbc -a -d -salt -pbkdf2 -pass pass:"$CHAVE_MESTRA"
}

adicionar_senha() {
  echo -n "Nome de Usuário: "
  read usuario
  echo -n "Senha: "
  read -s senha
  echo ""
  echo -n "Serviço: "
  read servico

  senha_encriptada=$(encriptar "$senha")
  echo "$usuario:$senha_encriptada:$servico" >> "$SENHAS_ARQUIVO"
  echo "Senha adicionada com sucesso para $usuario@$servico"
}

remover_senha() {
  echo -n "Nome de Usuário: "
  read usuario
  echo -n "Serviço: "
  read servico

  sed -i "/^$usuario:$servico/d" "$SENHAS_ARQUIVO"
  echo "Senha removida com sucesso para $usuario@$servico"
}
#Ainda n está bem a funcionar!!!!!!#
#atualizar_senha() {
#  echo -n "Nome de Usuário: "
#  read usuario
#  echo -n "Serviço: "
#  read servico

#  senha_encriptada=$(encriptar "$(dialog --passwordbox "Nova Senha:" 10 30 3>&1 1>&2 2>&3 3>&1)")
#  sed -i "/^$usuario:$servico/d" "$SENHAS_ARQUIVO"
#  echo "$usuario:$senha_encriptada:$servico" >> "$SENHAS_ARQUIVO"
#  echo "Senha atualizada com sucesso para $usuario@$servico"
#}

atualizar_senha() {
    echo Funcionalidade em Desenvolvimento
}

listar_senhas() {
  echo "Lista de Senhas:"
  while IFS=: read -r usuario senha servico; do
    senha_desencriptada=$(desencriptar "$senha")
    echo "Usuário: $usuario, Senha: $senha_desencriptada, Serviço: $servico"
  done < "$SENHAS_ARQUIVO"
}

gerar_senha_aleatoria() {
  tr -dc '[:alnum:]' < /dev/urandom | fold -w 12 | head -n 1
}

case "$1" in
  -a | --adicionar)
    adicionar_senha
    ;;
  -r | --remover)
    remover_senha
    ;;
  -u | --atualizar)
    atualizar_senha
    ;;
  -l | --listar)
    listar_senhas
    ;;
  -g | --gerar)
    gerar_senha_aleatoria
    ;;
  -h | --ajuda)
    mostrar_ajuda
    ;;
  *)
    mostrar_ajuda
    ;;
esac

exit 0
