#!/bin/bash

sudo apt update && sudo apt upgrade –y

sudo apt install docker.io

# Inicia e habilita o Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verifica se o Java está instalado
java -version #verifica versao atual do java
if [ $? = 0 ]; #se retorno for igual a 0
then #entao,
echo “java instalado” #print no terminal
else #se nao,
echo “java não instalado” #print no terminal
echo “gostaria de instalar o java? [s/n]” #print no terminal
read get #variável que guarda resposta do usuário
if [ \“$get\” == \“s\” ]; #se retorno for igual a s
then #entao
sudo apt install openjdk-17-jre -y #executa instalacao do java
fi #fecha o 2º if
fi #fecha o 1º if

# Verifica se o MySQL está instalado
mysql --version
if [ $? -eq 0 ]; then
  echo "MySQL instalado"
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
echo "Executando o container MySQL..."
sudo docker run -d -p 3306:3306 --name $NOME_CONTAINER -e "MYSQL_DATABASE=$NOME_DATABASE" -e "MYSQL_ROOT_PASSWORD=$SENHA_MYSQL" mysql:5.7

# Criar diretório para arquivos Node.js
ARQUIVOS_NODE_DIR="../arquivos_node/Site-Institucional"
mkdir -p "$ARQUIVOS_NODE_DIR"
cd "$ARQUIVOS_NODE_DIR" 

# Dockerfile para o site Node.js
echo "Criando o Dockerfile para o site Node.js"
cat <<EOF > Dockerfile
FROM node:latest
RUN apt-get update && apt-get install -y git
WORKDIR /arquivos_node
RUN git clone https://github.com/InfoTrack-SPTech/Site-Institucional.git
WORKDIR /arquivos_node/Site-Institucional
RUN npm install
EXPOSE 80
CMD ["npm", "start"]
EOF

# Build da imagem Node.js
echo "Construindo a imagem Node.js"
sudo docker build -t node-site .

# Executa o container Node.js
echo "Executando o container Node.js"
sudo docker run -d --name ContainerSite -p 80:80 node-site

echo "Setup concluído com sucesso"
