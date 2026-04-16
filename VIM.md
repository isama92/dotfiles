# VIM & Neovim

## VIM

### Installation

```bash
sudo apt install vim
```

### Plugins

Install [vim-plug](https://github.com/junegunn/vim-plug):

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/juneguyen/vim-plug/master/plug.vim
```

Open vim and run `:PlugInstall` to install plugins.

## Neovim

### Requirements

```bash
sudo apt-get install fuse libfuse2 git python3-pip ack-grep -y
```

### Installation

```bash
wget --quiet https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage --output-document nvim
chmod +x nvim
sudo chown root:root nvim
sudo mv nvim /usr/bin
mkdir -p ~/.config/nvim
```

### Plugins

Install [vim-plug](https://github.com/juneguyen/vim-plug) for Neovim:

```bash
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/juneguyen/vim-plug/master/plug.vim'
pip3 install --user neovim
```

Open nvim and run `:PlugInstall` to install plugins.
