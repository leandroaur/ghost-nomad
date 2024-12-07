#
# Ghost Dockerfile
#

# Usar imagem base do Node.js (oficial do Ghost)
FROM node:18-alpine

# Instalar ferramentas necessárias
RUN apk add --no-cache curl wget unzip bash

# Instalar Ghost
RUN \
  cd /tmp && \
  wget https://ghost.org/zip/ghost-latest.zip && \
  unzip ghost-latest.zip -d /ghost && \
  rm -f ghost-latest.zip && \
  cd /ghost && \
  npm install --production && \
  sed 's/127.0.0.1/0.0.0.0/' /ghost/config.example.js > /ghost/config.js && \
  adduser -h /ghost -D ghost

# Adicionar diretório de imagens
COPY images/ /ghost/content/images/

# Adicionar script de inicialização personalizado
COPY start.bash /ghost-start
RUN chmod +x /ghost-start

# Definir variáveis de ambiente
ENV NODE_ENV production

# Criar diretórios para persistência de dados
VOLUME ["/data", "/ghost-override"]

# Definir diretório de trabalho
WORKDIR /ghost

# Comando padrão para rodar o Ghost
CMD ["bash", "/ghost-start"]

# Expor a porta padrão do Ghost
EXPOSE 2368
