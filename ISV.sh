#!/bin/bash

echo "Calculadora de ISV - Importação de Carro (Tabela A do ACP)"

# Solicitar informações do veículo
echo "Digite a cilindrada do veículo (em centímetros cúbicos):"
read cilindrada

echo "Digite as emissões de CO2 do veículo (em gramas por quilômetro):"
read emissao_co2

echo "Digite o tipo de combustível (gasolina, diesel, elétrico, etc.):"
read combustivel

echo "Digite o ano de fabricação do veículo:"
read ano_fabricacao

echo "Digite a origem do veículo (nacional ou importado):"
read origem

echo "Digite o preço a pagar para legalização do veículo:"
read preco_legalizacao

# Definir constantes baseadas na Tabela A do ACP
taxa_cilindrada=0,01
taxa_co2=5,0
taxa_gasolina=1,1
taxa_diesel=1,2
taxa_eletrico=0,5
taxa_idade=0,95
taxa_importado=1,15

# Calcular o ISV baseado nas características do veículo
isv_cilindrada=$((cilindrada * taxa_cilindrada))
isv_co2=$((emissao_co2 * taxa_co2))

case $combustivel in
    gasolina)
        taxa_combustivel=$taxa_gasolina
        ;;
    diesel)
        taxa_combustivel=$taxa_diesel
        ;;
    eletrico)
        taxa_combustivel=$taxa_eletrico
        ;;
    *)
        echo "Tipo de combustível desconhecido."
        exit 1
        ;;
esac

isv_combustivel=$((isv_cilindrada + isv_co2))
isv_combustivel=$(echo "scale=2; $isv_combustivel * $taxa_combustivel" | bc)

# Calcular o desconto de idade
idade_veiculo=$((2024 - ano_fabricacao))
isv_idade=$((isv_combustivel * (idade_veiculo * taxa_idade)))

# Aplicar taxa de importação
if [ "$origem" == "importado" ]; then
    isv_importado=$(echo "scale=2; $isv_idade * $taxa_importado" | bc)
else
    isv_importado=$isv_idade
fi

# Calcular o ISV total, incluindo o preço de legalização
isv_total=$(echo "scale=2; $isv_importado + $preco_legalizacao" | bc)

echo "Detalhes do cálculo:"
echo "  ISV Cilindrada: $isv_cilindrada euros"
echo "  ISV CO2: $isv_co2 euros"
echo "  ISV Combustível: $isv_combustivel euros"
echo "  Desconto de Idade: $isv_idade euros"
echo "  ISV Importado: $isv_importado euros"
echo "  ISV Total (incluindo legalização): $isv_total euros"