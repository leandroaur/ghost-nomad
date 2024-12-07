#!/bin/bash

# Copiar arquivos de override, se existirem
if [ -d "/ghost-override" ]; then
  cp -R /ghost-override/* /ghost/
fi

# Iniciar o Ghost
node index.js

