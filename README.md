
# ColetaCerta - Operating Systems

## Sobre o projeto

Infraestrutura Linux desenvolvida para dar suporte à solução ColetaCerta, projeto acadêmico da FIAP - Global Solution 2026.2.

O objetivo é provisionar e administrar um ambiente Linux capaz de hospedar a aplicação, automatizar configurações e monitorar recursos do sistema.

## Tecnologias utilizadas

- Ubuntu 24.04 LTS
- WSL 2
- Bash
- systemd
- rsyslog
- Git

## Estrutura do projeto

- scripts/: scripts de automação e provisionamento.
- services/: serviços systemd.
- logs/: registros e auditoria.
- evidencias/: evidências dos testes.
- config/: arquivos de configuração.

## Funcionalidades previstas

- Provisionamento automatizado.
- Configuração de rede e hostname.
- Instalação de dependências.
- Inicialização automática de serviços.
- Monitoramento de CPU, memória e disco.
- Registro de logs e auditoria.
- Testes de falha e recuperação.

## Ambiente

Ubuntu 24.04.5 LTS executado em WSL 2.

## Status

Infraestrutura em desenvolvimento.
