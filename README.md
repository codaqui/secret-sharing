# Secret Sharing

[![🇧🇷 Português](https://img.shields.io/badge/🇧🇷-Português-green)](README.md) [![🇺🇸 English](https://img.shields.io/badge/🇺🇸-English-blue)](README_EN.md)

## Script de Compartilhamento de Segredos via Piping Server

Este script é uma utilidade para criar e compartilhar segredos através do Piping Server. O segredo criado é temporário e só pode ser acessado uma vez.

Você pode saber mais sobre o Piping Server [aqui](https://github.com/nwtgck/piping-server/tree/develop)

### Pré-requisitos

Certifique-se de ter instalado as seguintes dependências:

- `curl`
- `yq`
- `uuidgen`
- `pbcopy`

Se não tiver, instale-os usando seu gerenciador de pacotes (Pacman, APT, Yum, etc).

Você precisará de um Piping Server, você pode usar o nosso:

- `https://ping.enderson.dev`

### Uso

Após a instalação, execute o script no terminal usando:

```bash
bash main.sh
```

![Exemplo de uso em GIF](docs/example-create.gif)
