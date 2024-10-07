#!/bin/bash

# Criar arquivo LEIAME.TXT
touch LEIAME.TXT

# Criar diretório e script de instalação
mkdir script_instalacao
cd script_instalacao
touch instalacao.sh

# Tornar o script de instalação executável
chmod +x instalacao.sh

# Executar o script de instalação
./instalacao.sh

# Script de instalação

# Verifica se o Java está instalado
java -version
if [ $? -eq 0 ]; then
  echo "Java instalado"
else
  echo "Java não instalado"
  echo "Gostaria de instalar o Java? [s/n]"
  read get
  if [ "$get" == "s" ]; then
    sudo apt install openjdk-17-jre -y
  fi
fi

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

# Configuração do Docker para MySQL
NOME_CONTAINER="ContainerBD"
NOME_DATABASE="InfoTrack"
SENHA_MYSQL="root_password"  # Defina uma senha real aqui
DIRETORIO_SQL="caminho_para_sql"  # Diretório dos scripts SQL aqui

# Verifica se o Docker está instalado
docker --version
if [ $? -eq 0 ]; then
  echo "Docker instalado"
else
  echo "Docker não instalado"
  echo "Gostaria de instalar o Docker? [s/n]"
  read get
  if [ "$get" == "s" ]; then
    sudo apt install docker.io -y
  fi
fi

# Inicia e habilita o Docker
sudo systemctl start docker
sudo systemctl enable docker

# Baixar a imagem MySQL
sudo docker pull mysql:5.7

# Executa o container MySQL
sudo docker run -d -p 3306:3306 --name $NOME_CONTAINER -e MYSQL_DATABASE=$NOME_DATABASE -e MYSQL_ROOT_PASSWORD=$SENHA_MYSQL mysql:5.7

# Acessa o container MySQL
sudo docker exec -it $NOME_CONTAINER bash
mysql -u root -p

# Dockerfile para MySQL
cat <<EOF > Dockerfile
FROM mysql:latest
ENV MYSQL_ROOT_PASSWORD=$SENHA_MYSQL
COPY ./$DIRETORIO_SQL/ /docker-entrypoint-initdb.d/
EXPOSE 3306
EOF

# Build da imagem MySQL personalizada
sudo docker build -t minha-image-banco .

# Executa o container com a imagem personalizada
sudo docker run -d --name $NOME_CONTAINER -p 3306:3306 minha-image-banco

# Configuração do Docker para o site Node.js
NOME_CONTAINER="ContainerSite"

# Dockerfile para o site Node.js
cat <<EOF > Dockerfile-Node
FROM node:latest
WORKDIR /usr/src/app
RUN git clone https://github.com/InfoTrack-SPTech/Site-Institucional.git
WORKDIR /usr/src/app/Site-Institucional
RUN npm install
EXPOSE 80
CMD ["npm", "start"]
EOF

# Build da imagem Node.js
sudo docker build -f Dockerfile-Node -t imagem-node:v1 .

# Executa o container Node.js
sudo docker run -d --name $NOME_CONTAINER -p 80:80 imagem-node:v1
