# Zsh & Oh My Zsh

## Zsh

### Installation

```bash
sudo apt install zsh
```

## Oh My Zsh

### Installation

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Follow the procedure to set zsh as default shell.

## Powerlevel10k

### Installation

1. Install the [4 recommended fonts](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k)
2. Set `MesloLGS NF Regular` as your terminal font
3. Install powerline fonts and the theme:

```bash
sudo apt install fonts-powerline
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/^ZSH_THEME="\(.*\)"$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
```

4. Restart the terminal and follow the configuration wizard

## Plugins

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# k (directory listing)
git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k

# fzf (fuzzy finder)
sudo apt-get install fzf

# chroma (syntax highlighter)
sudo apt install chroma

# zsh-navigation-tools
sh -c "$(curl -fsSL https://raw.githubusercontent.com/psprint/zsh-navigation-tools/master/doc/install.sh)"
```

After installing plugins, add them to the `plugins` array in `~/.zshrc`:

```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting k fzf zsh-navigation-tools)
```
