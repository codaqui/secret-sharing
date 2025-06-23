# Secret Sharing

[![🇧🇷 Português](https://img.shields.io/badge/🇧🇷-Português-green)](README.md) [![🇺🇸 English](https://img.shields.io/badge/🇺🇸-English-blue)](README_EN.md)

## Piping Server Secret Sharing Script

This script is a utility for creating and sharing secrets through Piping Server. The created secret is temporary and can be only accessed once.

You can know more about Piping Server [here](https://github.com/nwtgck/piping-server/tree/develop)

### Prerequisites

Make sure you have installed the following dependencies:

- `curl`
- `yq`
- `uuidgen`
- `pbcopy`

If not, install them by using your package manager (Pacman, APT, Yum, etc).

You will need a Piping Server, you can use ours:

- `https://ping.enderson.dev`

### Usage

After installation, run the script by executing it in the terminal using:

```bash
bash main.sh
```

![Example of Usage in a GIF](docs/example-create.gif)
