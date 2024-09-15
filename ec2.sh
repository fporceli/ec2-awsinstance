#!/bin/bash

#Função para exibir o menu

exibir_menu() {
	clear
	echo " -----------------------------------------"
	echo "|             MENU EC2 MAKER              |"
	echo " -----------------------------------------"
	echo -e "Seja bem vindo ao gerador de instâncias automático! Por favor, escolha a próxima ação a ser tomada baseada em suas necessidades. \nCaso tenha dúvidas, selecione a opção X para entrar em contato conosco!\n"
	echo -e "[1] Instalar dependências e verificar versão\n[2] Realizar configuração e conexão de usuário AWS\n[3] Criar novo par de chaves\n[4] Criar grupo de segurança"

}

escolher_opcao() {
	read -p "Escolha a opção [1-X]: " opcao
	case $opcao in
		1)
			versao_aws=$(aws --version)
			sudo apt install awscli
			echo "Deependencias instaladas com sucesso! A versão atual do AWSCLI é $versao_aws"
			;;
		2)
			aws configure

			;;
		3)
			read -p "Qual nome deseja dar para a sua chave? " nome_chave
			aws ec2 create-key-pair --key-name $nome_chave --query 'KeyMaterial' --output text > $nome_chave.pem
			echo -e "\nPar de chaves criado com sucesso!\nAcesse o arquivo $nome_chave.pem para visualizar"
		;;
		4)
			read -p "Qual nome deseja dar ao grupo de segurança? " nome_grupo_seguranca
			read -p "Por favor, dê uma descrição detalhada para o grupo: " descricao_grupo_seguranca
			echo "Criando seu grupo..."
			aws ec2 create-security-group --group-name $nome_grupo_seguranca --description "$descricao_grupo_seguranca" > /dev/null
			id_grupo=$(aws ec2 describe-security-groups --filters Name=group-name,Values="$nome_grupo_seguranca" --query 'SecurityGroups[0].GroupId' --output text)

			echo -e "Grupo criado com sucesso!\nO Grupo $nome_grupo_seguranca foi criado com o id $id_grupo
"
		;;
	esac
}
exibir_menu
escolher_opcao


