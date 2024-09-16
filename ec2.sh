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

exibir_menu_gruposeguranca () {
	clear
        echo " -----------------------------------------"
        echo "|      MENU GROUP SECURITY EC2 MAKER      |"
        echo " -----------------------------------------"
        echo -e "Selecione a opção que deseja em relação aos grupos de segurança das instâncias EC2 da AWS"
        echo -e "[1] Criar novo grupo de segurança\n[2] Realizar configurações de Firewall\n[3] Consultar informações dos meus grupos\n[4] Voltar para o menu"

}

escolher_opcao() {
	read -p "Escolha a opção [1-X]: " opcao
	case $opcao in
		1)
			sudo apt install awscli -y
			versao_aws=$(aws --version)
			clear
			echo "Deependencias instaladas com sucesso! A versão atual do AWSCLI é $versao_aws"
			exibir_menu
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
			exibir_menu_gruposeguranca
			escolher_opcao_seguranca
			;;
	esac
}

escolher_opcao_seguranca() {
	read -p "Escolha a opção [1-4]: " opcao_seguranca
	case $opcao_seguranca in 
		1)
			read -p "Qual nome deseja dar ao grupo de segurança? " nome_grupo_seguranca
                        read -p "Por favor, dê uma descrição detalhada para o grupo: " descricao_grupo_seguranca
                        echo "Criando seu grupo..."
                        aws ec2 create-security-group --group-name $nome_grupo_seguranca --description "$descricao_grupo_seguranca" > /dev/null
                        id_grupo=$(aws ec2 describe-security-groups --filters Name=group-name,Values="$nome_grupo_seguranca" --query 'SecurityGroups[0].GroupId' --output text)

                        echo -e "Grupo criado com sucesso!\nO Grupo $nome_grupo_seguranca foi criado com o id $id_grupo"
			sleep 5
			exibir_menu_gruposeguranca
			escolher_opcao_seguranca
			;;
		2)
			clear
			ip_publico=$(curl https://checkip.amazonaws.com) 
			read -p "Qual o id do grupo de segurança? " id_grupoc
			aws ec2 authorize-security-group-ingress --group-id $id_grupoc --protocol tcp --port 22 --cidr $ip_publico/32
			aws ec2 authorize-security-group-ingress --group-id $id_grupoc --protocol tcp --port 22-8000 --cidr 0.0.0.0/0
			echo "Em construção..."
			sleep 3
			exibir_menu_gruposeguranca
			escolher_opcao_seguranca
			;;
		3)
			clear
			read -p "Qual o nome do grupo que você deseja consultar? " nome_grupo
			aws ec2 describe-security-groups --group-names $nome_grupo
			sleep 10
			exibir_menu_gruposeguranca
			escolher_opcao_seguranca
			;;
		4)
			echo "Saindo..."
			sleep 1
			exibir_menu
			escolher_opcao
			;;


	esac
}

exibir_menu
escolher_opcao
