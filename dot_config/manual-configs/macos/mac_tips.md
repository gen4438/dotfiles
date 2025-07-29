# macOS についてのメモ

---

## Mac を開くと自動で電源が入るのを防ぐ方法

https://kuneoresearch.com/macbookpro-2017-auto-boot-off/

自動起動オフにするコマンドは以下の通り。

```bash
sudo nvram AutoBoot=%00
```

やっぱり自動起動をオンにしておきたい、元に戻したいという時はこちらのコマンドを入力しましょう。

```bash
sudo nvram AutoBoot=%03
```

---

## Finder の Quit メニューを有効にする

```zsh
defaults write com.apple.Finder QuitMenuItem -boolean true
```

---

## デフォルトディレクトリの表示名を英語にする

```zsh
rm ~/Applications/.localized
rm ~/Documents/.localized
rm ~/Downloads/.localized
rm ~/Desktop/.localized
rm ~/Public/.localized
rm ~/Pictures/.localized
rm ~/Music/.localized
rm ~/Movies/.localized
rm ~/Library/.localized
```

---

## Google Chrome を開くエイリアス

```zsh
alias google-chrome='open /Applications/Google\ Chrome.app/'
```
