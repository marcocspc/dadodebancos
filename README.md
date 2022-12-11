# Dado de Bancos
Uma API para obter extratos de bancos brasileiros utilizando python, selenium e podman.

Estarei trabalhando no suporte inicial ao Banco do Brasil, para o código será extensível para outros bancos, de forma que outras pessoas possam colaborar.

Este é um projeto pessoal e de código fonte aberto, não possui nenhuma associação com instituições bancárias.

## Dependências

De forma resumida, as dependências são:

- Um servidor gráfico X (Xorg, XWayland ou XQuarts no mac) *somente necessário para o modo debug*
- Podman
- GNU Make

### Linux

No Linux, você precisará do podman e do make instalados. Algumas instruções de como instalar o podman podem ser encontradas [aqui](https://podman.io/getting-started/installation#installing-on-linux). Já o make vai depender muito de sua distribuição, vou deixar aqui instruções para 3 distribuições que considero base para muitos SOs Linux por aí afora:

- Debian/Ubuntu:
```
sudo apt-get install build-essential
```

- Fedora:
```
sudo yum -y install make
```

- Arch:
```
pacman -S make
```

Já o servidor gráfico X já é nativo na maioria das distribuições Linux, caso esteja usando Wayland, pode instalar o XWayland.

### MacOS

Já no MacOS tanto o podman quando o make podem ser instalados da seguinte forma:

```
brew install podman make 
```

O XQuartz, servidor X necessário para rodar o modo debug, pode ser obtido [aqui](https://www.xquartz.org). 

## Observações para MacOS

Antes de utilizar qualquer comando do Makefile, o podman precisa ser inicializado:

```
podman machine init
podman machine start
```

Lembre também de executar o XQuartz, ele precisa estar aberto antes de ser utilizado o modo debug.

## Criando a imagem

Clone ou baixe este repositório. Entre na pasta dele e digite:

```
make build
```

## Executando a API

*Em breve*

### Métodos da API

*Em breve*

## Rodando o container no modo Debug

Estando na pasta do repositório, basta digitar:

```
make start-debug
```

## O modo Debug

O modo debug é utilizado principalmente para verificar se o módulo do warsaw está sendo executado de forma correta. Quando o container é executado desta forma, uma janela do Chrome e um terminal (lxterminal) são abertos para propósitos de teste. Este modo também pode ser utilizado para a instalação do Selenium IDE para geração de scripts que façam web scrapping das páginas dos bancos.

### Criando novos scripts com o modo debug

Um script pode ser facilmente criado com a Selenium IDE. Em breve, quando atualizar mais esta documentação, detalharei passo a passo sobre como utilizar a extensão para facilmente gerar scripts para realizar raspagem de dados nas páginas. Por ora, deve-se saber que deve-se instalar, no modo debug, a extensão [Selenium IDE](https://chrome.google.com/webstore/detail/selenium-ide/mooikfkahbdckldjjndioackbalphokd) e utilizá-la para este fim.
