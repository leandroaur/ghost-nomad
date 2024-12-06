# Configurando Nomad, Consul e Fabio no seu Ambiente

## Introdução
Nomad, Consul e Fabio são ferramentas poderosas para gerenciar workloads, configurar serviços distribuídos e implementar balanceadores de carga. Este guia mostrará como instalá-los e configurá-los em um ambiente de homelab.

## Passo 1: Instalando o Nomad
1. **Faça o download do Nomad** no site oficial ou use um gerenciador de pacotes (ex.: `apt` ou `yum`).
![Logo do Nomad](../images/nomad-logo.svg)
2. **Configure o agente do Nomad**:
   - Crie o arquivo `nomad.hcl` com as configurações básicas.
   - Use o comando `nomad agent -dev` para testes.

## Passo 2: Instalando o Consul
1. Instale o Consul com `apt` ou baixe diretamente o binário.
2. Configure o agente do Consul:
   - Crie um arquivo `consul.hcl` para configurar o datacenter e a comunicação com outros agentes.

## Passo 3: Configurando Fabio como Load Balancer
1. Baixe o Fabio no [repositório oficial](https://github.com/fabiolb/fabio).
2. Adicione as configurações básicas no arquivo `fabio.properties`: registry.consul.addr=localhost:8500 registry.consul.tagprefix=urlprefix-
3. Inicie o Fabio e verifique se ele registra os serviços corretamente no Consul.

## Conclusão
Após seguir esses passos, você terá um ambiente funcional com Nomad, Consul e Fabio. Enfrentei problemas comuns como conflitos de portas e serviços não sendo registrados, que podem ser resolvidos ajustando configurações nos arquivos `*.hcl`.


