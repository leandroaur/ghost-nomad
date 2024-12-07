# Usar a imagem base do Ghost com Alpine
FROM ghost:5-alpine

# Adicionar ferramentas necessárias para manipulação de arquivos
RUN apk add --no-cache curl git

# Definir o diretório de trabalho
WORKDIR /var/lib/ghost

# Copiar o diretório de imagens para o container
COPY images/ /var/lib/ghost/content/images/

# Comando para rodar o Ghost
CMD ["docker-entrypoint.sh", "npm", "start"]
