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
  echo "$1" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$CHAVE_MESTRA"   #-aes-256-cbc nao funciona esta encriptação
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

  # Verifica se a entrada existe antes de tentar remover
  if grep -q "^$usuario:.*:$servico" "$SENHAS_ARQUIVO"; then
    # Remove a linha do arquivo
    sed -i "/^$usuario:.*:$servico/d" "$SENHAS_ARQUIVO"
    echo "Senha removida com sucesso para $usuario@$servico"
  else
    echo "Combinação de usuário e serviço não encontrada."
  fi
}

atualizar_senha() {
  echo -n "Nome de Usuário: "
  read usuario
  echo -n "Serviço: "
  read servico

  # Verifica se a entrada existe antes de tentar atualizar
  if grep -q "^$usuario:.*:$servico" "$SENHAS_ARQUIVO"; then
    echo -n "Nova Senha: "
    read -s nova_senha
    echo ""

    senha_encriptada=$(encriptar "$nova_senha")

    # Atualiza a linha no arquivo
    sed -i "s/^$usuario:.*:$servico/$usuario:$senha_encriptada:$servico/g" "$SENHAS_ARQUIVO"
    echo "Senha atualizada com sucesso para $usuario@$servico"
  else
    echo "Combinação de usuário e serviço não encontrada."
  fi
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
