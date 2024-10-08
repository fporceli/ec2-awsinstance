#!/bin/bash

#Função para exibir o menu

exibir_menu() {
	clear
	echo " -----------------------------------------"
	echo "|             MENU EC2 MAKER              |"
	echo " -----------------------------------------"
	echo -e "Seja bem vindo ao gerador de instâncias automático! Por favor, escolha a próxima ação a ser tomada baseada em suas necessidades. \nCaso tenha dúvidas, selecione a opção X para entrar em contato conosco!\n"
	echo -e "[1] Instalar dependências e verificar versão\n[2] Realizar configuração e conexão de usuário AWS\n[3] Criar novo par de chaves\n[4] Menu grupo de segurança\n[5] Consultar AMIs\n[6] Gerar instância EC2\n[7] Deletar instância"

}

exibir_menu_gruposeguranca () {
	clear
        echo " -----------------------------------------"
        echo "|      MENU GROUP SECURITY EC2 MAKER      |"
        echo " -----------------------------------------"
        echo -e "Selecione a opção que deseja em relação aos grupos de segurança das instâncias EC2 da AWS"
        echo -e "[1] Criar novo grupo de segurança\n[2] Realizar configurações de Firewall\n[3] Consultar informações dos meus grupos\n[4] Excluir grupo de segurança\n[5] Voltar para o menu"

}

exibir_menu_ami () {

	clear
	echo " -----------------------------------------"
        echo "|     MENU AMI DESCRIPTION EC2 MAKER      |"
        echo " -----------------------------------------"
        echo -e "Selecione as opções "
        echo -e "[1] Consultar AMIs do Ubuntu\n[2] Consultar AMIs do Debian\n[3] Consultar AMIs do CentOS\n[4] Consultar IDS de contas oficiais\n[5] Sair do menu"

}

exibir_menu_instancia () {

        clear
        echo " -----------------------------------------"
        echo "|             MENU EC2 MAKER              |"
        echo " -----------------------------------------"
	read -p "Qual o id da AMI que será usado? " ami_instancia
        read -p "Quantas instâncias deseja criar? " qtd_instancia
	read -p "Digite o nome do par de chaves que será usado: " chave_instancia
	read -p "Digite o nome do grupo de segurança que será usado: " grupo_instancia
	echo "Criando sua instância EC2..."
	criacao_instancia=$(aws ec2 run-instances --image-id $ami_instancia --count $qtd_instancia --instance-type t2.micro --key-name $chave_instancia --security-groups $grupo_instancia)
	id_instancia=$(echo "$criacao_instancia" | grep InstanceId | awk -F'"' '{print $4}')
	echo -e "Instância EC2 com o id: $id_instancia criada com sucesso!!\nRedirecionando para o menu..."
	if [ $? -eq 0 ]; then
        	data_atual=$(date +"%d/%m/%Y")
                hora_atual=$(date +"%H:%M")
                echo -e "$data_atual $hora_atual INFO EC2MAKER Nova instância criada\nId: $ami_instancia\nQuantidade: $qtd_instancia\nChave: $chave_instancia\nGrupo de segurança: $grupo_instancia" >> log.log
        	read -p "Dê um nome para sua instância: " nome_instancia
		aws ec2 create-tags --resources $id_instancia --tags Key=Name,Value=$nome_instancia
		echo "Nome atribuído com sucesso!"
	else
		data_atual=$(date +"%d/%m/%Y")
                hora_atual=$(date +"%H:%M")
		echo -e "$data_atual $hora_atual WARNING EC2MAKER Erro ao criar nova instancia" >> log.log
	fi
	echo -e "Pressione ENTER para voltar" 
	read
	exibir_menu
	escolher_opcao

}

exibir_menu_del_instancia (){
	clear
        echo " -----------------------------------------"
        echo "|             MENU EC2 MAKER              |"
        echo " -----------------------------------------"
	read -p "Digite o nome da instancia que deseja deletar: " instancia_del
	aws ec2 terminate-instances --instance-ids $instancia_del
	echo -e "Instância $instancia_del deletada com sucesso\nPressione ENTER para voltar ao menu!"
	read
	exibir_menu
	escolher_opcao

}  


escolher_opcao() {
	read -p "Escolha a opção [1-X]: " opcao
	if [ $opcao -lt 1 ] || [ $opcao -gt 6 ]; then
		echo "Você não digitou um número entre 1 e 6"
		escolher_opcao
	else
		case $opcao in
		1)
			sudo apt install awscli -y
			versao_aws=$(aws --version)
			clear
			echo "Deependencias instaladas com sucesso! A versão atual do AWSCLI é $versao_aws"
			exibir_menu
			data_atual=$(date +"%d/%m%/Y")
        		hora_atual=$(date +"%H:%M")
			echo -e "$data_atual $hora_atual INFO EC2MAKER - Versão e dependências verificadas" >> log.log 
			;;
		2)
			aws configure

			;;
		3)
			read -p "Qual nome deseja dar para a sua chave? " nome_chave
			aws ec2 create-key-pair --key-name $nome_chave --query 'KeyMaterial' --output text > $nome_chave.pem
			if [ $? -eq 0 ]; then
				echo -e "\nPar de chaves criado com sucesso!\nAcesse o arquivo $nome_chave.pem para visualizar"
				data_atual=$(date +"%d/%m/%Y")
                                hora_atual=$(date +"%H:%M")
                                echo -e "$data_atual $hora_atual INFO EC2MAKER Chave de acesso com o nome $nome_chave criada" >> log.log
				
			else
				data_atual=$(date +"%d/%m/%Y")
			        hora_atual=$(date +"%H:%M")
        			echo -e "$data_atual $hora_atual WARNING EC2MAKER Erro ao criar par de chaves" >> log.log

			fi
			;;
		4)
			exibir_menu_gruposeguranca
			escolher_opcao_seguranca
			;;
		5)
                        exibir_menu_ami
                        escolher_opcao_ami
                        ;;
		6)
			
			exibir_menu_instancia
			;;

	esac	
	fi
}

escolher_opcao_seguranca() {
	read -p "Escolha a opção [1-4]: " opcao_seguranca
	if [ $opcao_seguranca -lt 1 ] || [ $opcao_seguranca -gt 4 ]; then
            echo "Você não digitou um número entre 1 e 4"
            escolher_opcao_seguranca
    else
		case $opcao_seguranca in 
			1)
				read -p "Qual nome deseja dar ao grupo de segurança? " nome_grupo_seguranca
				read -p "Por favor, dê uma descrição detalhada para o grupo: " descricao_grupo_seguranca
				echo "Criando seu grupo..."
				aws ec2 create-security-group --group-name $nome_grupo_seguranca --description "$descricao_grupo_seguranca" > /dev/null 
				if [ $? -eq 0 ]; then
                                        data_atual=$(date +"%d/%m/%Y")
                                	hora_atual=$(date +"%H:%M")
                                	echo -e "$data_atual $hora_atual INFO EC2MAKER Grupo de segurança com o nome $nome_grupo_seguranca criado com sucesso!" >> log.log
                	        else
					data_atual=$(date +"%d/%m/%Y")
                                        hora_atual=$(date +"%H:%M")
                                        echo -e "$data_atual $hora_atual WARNING EC2MAKER Erro ao criar grupo de segurança $nome_grupo_seguranca" >> log.log
					echo "Erro ao criar grupo"
					exibir_menu_gruposeguranca
					escolher_opcao_seguranca
				fi
				id_grupo=$(aws ec2 describe-security-groups --filters Name=group-name,Values="$nome_grupo_seguranca" --query 'SecurityGroups[0].GroupId' --output text)
				echo -e "Grupo criado com sucesso!\nO Grupo $nome_grupo_seguranca foi criado com o id $id_grupo"
				echo -e "\nPressione enter para sair"
				read
				exibir_menu_gruposeguranca
				escolher_opcao_seguranca
				;;
			2)
				clear
				ip_publico=$(curl https://checkip.amazonaws.com) 
				read -p "Qual o id do grupo de segurança? " id_grupoc
				aws ec2 authorize-security-group-ingress --group-id $id_grupoc --protocol tcp --port 22 --cidr $ip_publico/32
				aws ec2 authorize-security-group-ingress --group-id $id_grupoc --protocol tcp --port 22-8000 --cidr 0.0.0.0/0
				echo -e "\nPressione enter para sair"
							read
							exibir_menu_gruposeguranca
							escolher_opcao_seguranca
				;;
			3)
				clear
				read -p "Qual o nome do grupo que você deseja consultar? " nome_grupo
				aws ec2 describe-security-groups --group-names $nome_grupo
				echo -e "\nPressione enter para sair"
							read
							exibir_menu_gruposeguranca
							escolher_opcao_seguranca

				;;
			4)
				clear
				read -p "Digite o nome do grupo que deseja deletar: " grupo_deletar
				read -p "Tem certeza que deseja deletar o grupo $grupo_deletar? (Y/N) " escolha
				if [ "$escolha" = "Y" ]; then
					echo "Deletando o grupo $grupo_deletar..."
					sleep 1
					aws ec2 delete-security-group --group-name $grupo_deletar
					echo -e "Grupo $grupo_deletar deletado com sucesso.\nVoltando para o menu..."
					for ((i=1; i<=total; i++)); do
                                        	echo -n "="
                                                sleep 0.03
	                                done
					exibir_menu_gruposeguranca
					escolher_opcao_seguranca
				else
					total=50
					echo "Voltando para o menu..."
					for ((i=1; i<=total; i++)); do
                                                echo -n "="
                                                sleep 0.03
        	                        done
					exibir_menu_gruposeguranca
					escolher_opcao_seguranca

				fi
				;;
			5)
				echo "Saindo..."
				total=50
				for ((i=1; i<=total; i++)); do
					echo -n "="
					sleep 0.01
				done
				exibir_menu
				escolher_opcao
				;;
		esac
		fi
}

escolher_opcao_ami () {

	read -p "Escolha uma opção[1-4]: " opcao_menu_ami
	if [ $opcao_menu_ami -lt 1 ] || [ $opcao_menu_ami -gt 5 ]; then
            echo "Você não digitou um número entre 1 e 5"
            escolher_opcao_ami
    	else
		case $opcao_menu_ami in
			1) 
				clear
				read -p "Digite o nome da AMI que deseja consultar: " nome_consulta_ami
				nome_consulta_ami_min=$(echo $nome_consulta_ami | tr '[:upper:]' '[:lower:]')
				echo "Consultando imagens oficiais do Ubuntu com o nome: $nome_consulta_ami_min "
				aws ec2 describe-images --filters "Name=name,Values=$nome_consulta_ami_min*" --owners 099720109477 --query 'Images[*].[ImageId,Name,Description]' --output table
				echo -e "\nPressione enter para sair"
							read
							exibir_menu_ami
							escolher_opcao_ami

				;;
			2)
				clear
							read -p "Digite o nome da AMI que deseja consultar: " nome_consulta_ami
							nome_consulta_ami_min=$(echo $nome_consulta_ami | tr '[:upper:]' '[:lower:]')
							echo "Consultando imagens oficiais do Debian com o nome: $nome_consulta_ami_min "
							aws ec2 describe-images --filters "Name=name,Values=$nome_consulta_ami_min*" --owners 136693071363 --query 'Images[*].[ImageId,Name,Description]' --output table
				echo -e "\nPressione enter para sair"
							read
							exibir_menu_ami
							escolher_opcao_ami
				;;
			3)
							clear
							read -p "Digite o nome da AMI que deseja consultar: " nome_consulta_ami
							nome_consulta_ami_min=$(echo $nome_consulta_ami | tr '[:upper:]' '[:lower:]')
							echo "Consultando imagens oficiais do CentOS com o nome: $nome_consulta_ami_min "
							aws ec2 describe-images --filters "Name=name,Values=\b$nome_consulta_ami_min*\b" --owners 125523088429 --query 'Images[*].[ImageId,Name,Description]' --output table
				echo -e "\nPressione enter para sair"
							read
							exibir_menu_ami
							escolher_opcao_ami
				;;
			4)
				cat officialimages.txt
				echo -e "\nPressione enter para sair"
				read
				exibir_menu_ami
				escolher_opcao_ami
				;;

			5)
				echo "Saindo..."
				total=50
				for ((i=1; i<=total; i++)); do
					# Imprimir "=" sem quebrar a linha
					echo -n "="
					# Pausar por 0.1 segundos (ajuste o tempo conforme necessário)
					sleep 0.03
				done
				exibir_menu
				escolher_opcao


		esac
		fi

}

exibir_menu
escolher_opcao
