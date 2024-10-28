#!/bin/bash

# Atualiza e instala pacotes necessários
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io -y

echo "******************************************"
echo "Inicializando e habilitando o Docker"
echo "******************************************"
# Inicia e habilita o Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verifica se o Java está instalado
java -version
if [ $? -eq 0 ]; then
  echo "******************************************"
  echo "Java instalado"
  echo "******************************************"
else
  echo "Java não instalado"
  echo "Gostaria de instalar o Java? [s/n]"
  read get
  if [ "$get" = "s" ]; then
    sudo apt install openjdk-21-jre -y
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
  if [ "$get" = "s" ]; then
    sudo apt install mysql-server -y
  fi
fi

# Baixar a imagem MySQL
sudo docker pull mysql:5.7

# Configuração do Docker para MySQL
NOME_CONTAINER="ContainerBD"
NOME_DATABASE="InfoTrack"
SENHA_MYSQL="12345"


sudo systemctl stop mysql

# Executa o container MySQL com as variáveis de ambiente necessárias
echo "******************************************"
echo "Executando o container MySQL"
echo "******************************************"
sudo docker run -d -p 3306:3306 --name $NOME_CONTAINER -e MYSQL_DATABASE=$NOME_DATABASE -e MYSQL_ROOT_PASSWORD=$SENHA_MYSQL mysql:5.7

# Executa o script SQL dentro do container
#echo "******************************************"
#echo "Copiando o arquivo SQL para o container"
#echo "******************************************"
#sudo docker exec "$NOME_CONTAINER" mkdir -p /tmp/tabelas
#sudo docker cp "$SCRIPT_SQL" "$NOME_CONTAINER":/tmp/

#echo "******************************************"
#echo "Executando o script SQL dentro do container"
#echo "******************************************"
#docker exec -i "$NOME_CONTAINER" mysql -u root -p"$SENHA_MYSQL" "$NOME_DATABASE" < /tmp/"$SCRIPT_SQL"

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
sudo docker run -d --name ContainerSite -p 8080:80 node-site

echo "******************************************"
echo "Setup concluído com sucesso"
echo "******************************************"

echo "******************************************"
echo "Listando os containers Docker"
echo "******************************************"
sudo docker ps -a
