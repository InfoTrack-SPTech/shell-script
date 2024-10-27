#!/bin/bash

sudo apt update && sudo apt upgrade –y
sudo apt install docker.io
echo "******************************************"
echo “Inicializando e habilitando o Docker”
echo "******************************************"
# Inicia e habilita o Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verifica se o Java está instalado
java -version #verifica versao atual do java
if [ $? = 0 ]; #se retorno for igual a 0
then #entao,
  echo "******************************************"
  echo “java instalado” 
  echo "******************************************"
else #se nao,
  echo “java não instalado” 
  echo “gostaria de instalar o java? [s/n]” 
  read get #variável que guarda resposta do usuário
  if [ \“$get\” == \“s\” ]; then
    sudo apt install openjdk-21-jre -y #executa instalacao do java
  fi 
fi 

# Verifica se o MySQL está instalado
mysql --version
if [ $? -eq 0 ]; then
  echo "******************************************"
  echo "MySQL instalado"
  echo "******************************************"
else
  echo "MySQL não instalado"
  echo "Gostaria de instalar o MySQL? [s/n]"
  read get
  if [ "$get" == "s" ]; then
    sudo apt install mysql-server -y
  fi
fi


# Baixar a imagem MySQL
sudo docker pull mysql:5.7

# Configuração do Docker para MySQL
NOME_CONTAINER="ContainerBD"
NOME_DATABASE="InfoTrack"
SENHA_MYSQL="123"

# Executa o container MySQL com as variáveis de ambiente necessárias
echo "******************************************"
echo "Executando o container MySQL"
echo "******************************************"
sudo docker run -d -p 3306:3306 --name $NOME_CONTAINER -e "MYSQL_DATABASE=$NOME_DATABASE" -e "MYSQL_ROOT_PASSWORD=$SENHA_MYSQL" mysql:5.7

# Criar diretório para arquivos Node.js
ARQUIVOS_NODE_DIR="../arquivos_node/Site-Institucional"
mkdir -p "$ARQUIVOS_NODE_DIR"
cd "$ARQUIVOS_NODE_DIR" 

# Dockerfile para o site Node.js
echo "******************************************"
echo "Criando o Dockerfile para o site Node.js"
echo "******************************************"

cat <<EOF > Dockerfile
FROM node:latest
RUN apt-get update && apt-get install -y git
WORKDIR /arquivos_node
RUN git clone https://github.com/InfoTrack-SPTech/Site-Institucional.git
WORKDIR /arquivos_node/Site-Institucional
RUN npm install
EXPOSE 80
CMD ["tail", "-f", "/dev/null"]
EOF

# Build da imagem Node.js
echo "******************************************"
echo "Construindo a imagem Node.js"
echo "******************************************"
sudo docker build -t node-site .

# Executa o container Node.js
echo "******************************************"
echo "Executando o container Node.js"
echo "******************************************"
sudo docker run -d --name ContainerSite -p 80:80 node-site

echo "******************************************"
echo "Setup concluído com sucesso"
echo "******************************************"

echo "******************************************"
echo "Listando os containers Docker"
echo "******************************************"
sudo docker ps -a
echo "******************************************"
echo "Executando o Docker do Site"
echo "******************************************"
sudo docker exec -it ContainerSite bash
