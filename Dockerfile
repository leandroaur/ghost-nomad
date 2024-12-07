# Use a imagem oficial do Ghost como base
FROM ghost:5-alpine

# Variáveis de ambiente para configuração básica
ENV GHOST_CONTENT /var/lib/ghost/content

# Copiar configurações personalizadas, se necessário
# Exemplo: Adicionar temas, configurar email ou outro conteúdo
# COPY ./seus-temas /var/lib/ghost/content/themes

# Copiar imagens para o diretório de conteúdo do Ghost
COPY images/ /var/lib/ghost/content/images/bucket/

# Configuração de permissões (caso necessário)
RUN chown -R node:node $GHOST_CONTENT

# Expor a porta usada pelo Ghost
EXPOSE 2368

# Executa o Ghost automaticamente ao iniciar o container
CMD ["node", "current/index.js"]
