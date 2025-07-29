# apt package install

## 基本

```bash
apt install -y build-essential ripgrep direnv xclip etckeeper cmake nfs-common samba-common cifs-utils jq jo fd-find bat
apt install -y universal-ctags
apt install -y exfat-utils exfat-fuse
apt install -y software-properties-common

add-apt-repository -y ppa:git-core/ppa
apt install -y git

# grpc
apt install -y protobuf-compiler
```

## tmux-xpanes

[tmux-xpanes](https://github.com/greymd/tmux-xpanes)

```bash
add-apt-repository ppa:greymd/tmux-xpanes -y
apt install -y tmux-xpanes
```

## pyenv 用

```bash
apt install -y make build-essential libssl-dev zlib1g-dev \
 libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
 libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

## デスクトップ

```bash
# Ubuntu 20.04
apt install -y gnome-tweak-tool gnome-shell-extensions
# Ubuntu 22.04
apt install -y gnome-tweaks gnome-shell-extensions

# IME
apt install -y fcitx5-mozc

# ファイルマネージャ
apt install -y nemo

# 圧縮・解凍
apt install -y p7zip-full p7zip-rar unrar

# スクリーンショット
apt install -y flameshot peek

# カラーピッカー
apt install -y yad

# dconf-editor
apt install -y dconf-editor

# 仮想マシン
apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# fsearch
add-apt-repository ppa:christian-boxdoerfer/fsearch-daily -y
apt install -y fsearch
```

## ラップトップ

```bash
apt install -y tlp powertop
```

## rhythmbox のプラグイン

```bash
add-apt-repository ppa:fossfreedom/rhythmbox-plugins
apt install -y rhythmbox-plugin-playlist-import-export
```

## vim 用

```bash
apt install -y git gettext libtinfo-dev \
 build-essential \
 libxmu-dev libgtk-3-dev libxpm-dev \
 libperl-dev python2-dev python3-dev ruby-dev \
 lua5.3 liblua5.3-dev luajit libluajit-5.1-dev \
 autoconf automake cproto
```

## neovim

[Neovim install guide](https://github.com/neovim/neovim/wiki/Installing-Neovim)

```bash
add-apt-repository ppa:neovim-ppa/unstable -y
add-apt-repository ppa:neovim-ppa/stable -y
apt install -y neovim

# GUI
apt install -y neovim-qt
```

### snap でインストール

```bash
snap install nvim --classic
```

## フォント

```bash
# 日本語
apt install -y fonts-takao fonts-ipafont fonts-ipaexfont
# MSフォント
apt install -y ttf-mscorefonts-installer

fc-cache -fv
```

## ツール

```bash
apt install -y zeal
apt install -y vifm
```

## GitHub CLI

```bash
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

# 認証
gh auth login
```

## ベンチマーク

```bash
apt install sysbench

sysbench cpu --threads=8 run
```

## チートシート

```bash
snap install cheat
```

## ターミナル画像表示

```bash
snap install timg
```
