# ファイル操作
if type trash-put &> /dev/null
then
  alias rm=trash-put
fi

# vim
alias vi=nvim
alias vim=nvim
alias vimdiff='nvim -d'
alias todo="vim ${MEMO_DIR}/todo.md"
alias memo="vim ${MEMO_DIR}/$(date +'%Y')_memo.md"
alias memoToday="vim ${MEMO_DIR}/$(date +'%Y-%m-%d')_memo.md"

# bash コマンド
alias mv='mv -i'
alias cp='cp -i'
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"
alias cdgit='cd "$(git rev-parse --show-toplevel)"'
alias less='less -R'
alias gd="pushd"
alias bd="popd"

# クリップボード
alias clip='pbcopy'
alias yp='pwd | clip'
alias yy='pwd | clip'
alias yd='pwd | clip'

# 略語
alias xo='xdg-open'
alias da='direnv allow'
alias dr='direnv reload'
alias de='direnv edit'
alias gc='google-chrome'
alias LANG_ja='LANG=ja_JP.UTF-8'
alias glr='gitlab-runner exec docker'
alias gb='git branch'
alias gco='git checkout'
alias gl='git log'
alias dcup='docker-compose up'
alias dcupd='docker-compose up -d'
alias dcupb='docker-compose up --build'
alias dcupbd='docker-compose up --build -d'
alias lpb='lab project browse'

# github cli
alias ghpr='gh pr list'
alias ghprc='gh pr checkout'
alias ghil='gh issue list'
alias ghis='gh issue show'
alias ghist='gh issue status'
alias ghie='gh issue edit'
alias ghic='gh issue create'

# 便利
alias pip_install_essentials="pip install -U pip ipython isort black flake8"
alias pip_upgrade_all="pip list -o | tail -n +3 | awk '{ print \$1 }' | xargs pip install -U"
alias gogh='bash -c  "$(wget -qO- https://git.io/vQgMr)"'
alias openssl_register_password='openssl rsautl -encrypt -inkey ~/.ssh/id_rsa_nopass'
alias xpanes_ssh='xpanes -tc "ssh {}"'
alias google_drive_mount='google-drive-ocamlfuse /mnt/google-drive'
alias bs_start='browser-sync start --server --files="**/*.html, **/*.css, **/*.js"'
alias bs_start_here='browser-sync start --server --files="*.html, *.css, *.js"'
alias j2p='jupyter-nbconvert --to python'
alias jl='nohup jupyter-lab > /dev/null 2>&1 &'
alias jn='nohup jupyter-notebook > /dev/null 2>&1 &'

# デフォルト値セットして実行
alias battery_80='echo 80 | sudo tee /sys/devices/platform/lg-laptop/battery_care_limit'
alias battery_100='echo 100 | sudo tee /sys/devices/platform/lg-laptop/battery_care_limit'
alias wine='LC_ALL=ja_JP.UTF-8 wine'
alias lsync='lsyncd -delay 1 -nodaemon -rsyncssh'
alias marp_watch='marp -w --html'

alias byobu_sync='tmux set-window-option synchronize-panes on'
alias byobu_sync_off='tmux set-window-option synchronize-panes off'
alias byobu_kill_session='a=(`byobu ls | cut -d " " -f 1`); byobu ls | cat -n; read b; byobu kill-session -t ${a[$b-1]}'
alias update_display='export DISPLAY=$(tmux show-env | sed -n "s/^DISPLAY=//p")'
