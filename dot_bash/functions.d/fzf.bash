#!/bin/bash

# v - open files in ~/.viminfo
v() {
  local files
  files=$(grep '^>' ~/.viminfo | cut -c3- |
          while read line; do
            [ -f "${line/\~/$HOME}" ] && echo "$line"
          done | fzf-tmux -d -m -q "$*" -1) && vim ${files//\~/$HOME}
}

# xpanes + fzf でホストを選ぶ（デフォルトはsshを実行）
function fssh() {
    local xpanes_cmd=${1:-ssh}
    local sshConfigHost=`cat ~/.ssh/config | grep -wi host |  grep -v "*" |  awk '{print $2}'`
    local sshConfigHostSub=`cat ~/.ssh/config.d/*.conf | grep -wi host | grep -v "*" |  awk '{print $2}'`
    local etcHost=`cat /etc/hosts | grep "^[^#]" | awk '{print $2}'`
    local sshLoginHost=`echo -e "${sshConfigHost}${sshConfigHost:+\n}${sshConfigHostSub}${sshConfigHostSub:+\n}${etcHost}" | fzf -m --reverse`
    if [ "$sshLoginHost" = "" ]; then
        return 1
    fi
    history -s xpanes -tc '"'${xpanes_cmd} {}'"' ${sshLoginHost}
    xpanes -tc "${xpanes_cmd} {}" ${sshLoginHost}
}

# pyenvの切替
function fpyenv() {
  if command -v pyenv 1>/dev/null 2>&1; then
    local target
    target=$(pyenv versions | fzf --no-hscroll --no-multi --ansi |  sed -e 's/(.*)//' -e 's/\*//' -e 's/ \+//g') || return
    pyenv shell "$target"
  fi
}

# pyevn-virtualenvの切替
function fpyenv-virtualenv() {
  if command -v pyenv 1>/dev/null 2>&1; then
    local target
    target=$(pyenv virtualenvs | fzf --no-hscroll --no-multi --ansi |  sed -e 's/(.*)//' -e 's/\*//' -e 's/ \+//g') || return
    pyenv activate "$target"
  fi
}

# conda env の切り替え
function fconda() {
  if command -v conda 1>/dev/null 2>&1; then
    local target
    target=$(conda env list | grep -v "^#" | grep -e "\S" | fzf --no-hscroll --no-multi --ansi | sed -e 's/\s.*//') || return
    conda activate "$target"
  fi
}

# docker 系

# docker イメージ選択
_fzf_docker_image() {
  local selected="$(docker images | sed 1d | fzf -q "$1" --no-sort -m --tac | awk '{ printf "%s:%s",$1,$2 }')"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}";
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

# docker コンテナ選択
_fzf_docker_container() {
  local selected="$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}";
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

# Select a docker container to start and attach to
function fda() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -1 -q "$1" | awk '{print $1}')

  if [ -n "$cid" ]; then
    history -s 'docker start '''"$cid"''' && docker attach '''"$cid"''''
    docker start "$cid" && docker attach "$cid"
  fi
}

# Select a running docker container to stop
function fds() {
  local cid
  cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')

  [ -n "$cid" ] && docker stop "$cid"
}

# Select docker containers to remove
function fdrm() {
  local target
  target=$(docker ps -a | sed 1d | fzf -m --tac)
  if [[ $target == "" ]]; then
    return
  fi
  history -s docker rm $(awk '{printf $1}' <<<"$target")
  docker rm $(awk '{print $1}' <<<"$target")
}

# Select a docker image or images to remove
function fdrmi() {
  local target
  target=$(docker images | sed 1d | fzf -m --tac)
  if [[ $target == "" ]]; then
    return
  fi
  history -s docker rmi $(awk '{ printf "%s:%s",$1,$2 }' <<<"$target")
  docker rmi $(awk '{print $3}' <<<"$target")
}

# Select docker volumes to remove
function fdrmv() {
  local target
  target=$(docker volume ls | sed 1d | fzf -m --tac)
  if [[ $target == "" ]]; then
    return
  fi
  history -s docker rmi $(awk '{ printf "%s:%s",$1,$2 }' <<<"$target")
  docker volume rm $(awk '{print $3}' <<<"$target")
}

# Select a docker image to run
function fdr() {
  local target
  target=$(docker images | sed 1d | fzf)
  if [[ $target == "" ]]; then
    return
  fi
  history -s docker run -it --rm $(awk '{ printf "%s:%s",$1,$2 }' <<<"$target") "$@"
  docker run -it --rm $(awk '{print $3}' <<<"$target") "$@"
}

# kubernetesのエイリアス実行
function fk() {
    k8s_alias=$(grep ^alias ~/.kubectl_aliases | sed -e "s/alias //" | fzf --no-hscroll --no-multi --ansi)
    k8s_command=$(echo ${k8s_alias} | sed -e "s/.*='\(.*\)'/\1/")
    k8s_alias=$(echo ${k8s_alias} | sed -e "s/alias \(.*\)=.*'/\1/")
    if [ ! -z "${k8s_command}" ]; then
        echo ${k8s_alias} = ${k8s_command}
        ${k8s_command}
    fi
}

# git と連携

# git worktreeへ移動
cdwt() {
    # カレントディレクトリがGitリポジトリ上かどうか
    git rev-parse &>/dev/null
    if [ $? -ne 0 ]; then
        echo fatal: Not a git repository.
        return
    fi
    local selectedWorkTreeDir=`git worktree list | fzf | awk '{print $1}'`
    if [ "$selectedWorkTreeDir" = "" ]; then
        # Ctrl-C.
        return
    fi
    cd ${selectedWorkTreeDir}
}

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

_gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

_gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##' |
  tr '\n' ' '
}

_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

_gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

_gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

_gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

# fbr - checkout git branch (including remote branches)
fgbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fco - checkout git branch/tag
fgco() {
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi) || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

# fco_preview - checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
fgco_preview() {
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'") || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

# fcoc - checkout git commit
fgcoc() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

# gh issue を fzf で選択して選択した issue 番号の内容を表示。
# その後 comment?: y/[n] をプロンプトで聞いて、y としたら issue にコメントを追加する。
# ghi に対する引数はそのまま gh issue list に与える。
ghi() {
  local issue

  # issue=$(gh issue list | fzf --no-multi --ansi | awk '{print $1}')
  issue=$(gh issue list $@ | fzf --no-multi --ansi | awk '{print $1}')
  if [ "$issue" = "" ]; then
    # Ctrl-C.
    return
  fi
  gh issue view --comments ${issue}
  read -p "comment?: y/[n] " yn
  case "$yn" in
    [yY]*) gh issue comment ${issue} ;;
    *) ;;
  esac
}

# gh pr を fzf で選択して選択した pr 番号の内容を表示。
# その後 comment?: y/[n] をプロンプトで聞いて、y としたら pr にコメントを追加する。
# ghi に対する引数はそのまま gh pr list に与える。
ghp() {
  local pr

  # pr=$(gh pr list | fzf --no-multi --ansi | awk '{print $1}')
  pr=$(gh pr list $@ | fzf --no-multi --ansi | awk '{print $1}')
  if [ "$pr" = "" ]; then
    # Ctrl-C.
    return
  fi
  gh pr view --comments ${pr}
  read -p "comment?: y/[n] " yn
  case "$yn" in
    [yY]*) gh pr comment ${pr} ;;
    *) ;;
  esac
}

# キーバインド
# 参考: ~/.fzf/shell/key-bindings.bash
if [[ $- =~ i ]]; then
  # Required to refresh the prompt after fzf
  bind -m emacs-standard '"\er": redraw-current-line'

  bind -m vi-command '"\C-z": emacs-editing-mode'
  bind -m vi-insert '"\C-z": emacs-editing-mode'
  bind -m emacs-standard '"\C-z": vi-editing-mode'

  bind -m emacs-standard '"\C-g\C-f": " \C-b\C-k \C-u`_gf`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
  bind -m emacs-standard '"\C-g\C-b": " \C-b\C-k \C-u`_gb`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
  bind -m emacs-standard '"\C-g\C-t": " \C-b\C-k \C-u`_gt`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
  bind -m emacs-standard '"\C-g\C-h": " \C-b\C-k \C-u`_gh`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
  bind -m emacs-standard '"\C-g\C-r": " \C-b\C-k \C-u`_gr`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
  bind -m emacs-standard '"\C-g\C-s": " \C-b\C-k \C-u`_gs`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'

  bind -m vi-command '"\C-g\C-f": "\C-z\C-g\C-f\C-z"'
  bind -m vi-command '"\C-g\C-b": "\C-z\C-g\C-b\C-z"'
  bind -m vi-command '"\C-g\C-t": "\C-z\C-g\C-t\C-z"'
  bind -m vi-command '"\C-g\C-h": "\C-z\C-g\C-h\C-z"'
  bind -m vi-command '"\C-g\C-r": "\C-z\C-g\C-r\C-z"'
  bind -m vi-command '"\C-g\C-s": "\C-z\C-g\C-s\C-z"'

  bind -m vi-insert '"\C-g\C-f": "\C-z\C-g\C-f\C-z"'
  bind -m vi-insert '"\C-g\C-b": "\C-z\C-g\C-b\C-z"'
  bind -m vi-insert '"\C-g\C-t": "\C-z\C-g\C-t\C-z"'
  bind -m vi-insert '"\C-g\C-h": "\C-z\C-g\C-h\C-z"'
  bind -m vi-insert '"\C-g\C-r": "\C-z\C-g\C-r\C-z"'
  bind -m vi-insert '"\C-g\C-s": "\C-z\C-g\C-s\C-z"'
fi


# fzf で カレントディレクトリ直下のファイル、隠しファイルを含むを対象、recursive しない
_fzf_current_dir_files() {
  shopt -s dotglob
  local files
  files=$(printf "%s\n" *)
  shopt -u dotglob

  local selected
  selected=$(printf "%s\n" "$files" | fzf --no-hscroll --no-multi --ansi) || return 1

  # 選択結果を readline の入力行に挿入
  # 現在カーソル位置 READLINE_POINT の位置に挿入
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

# bash の readline に登録
bind -x '"\C-f\C-f": _fzf_current_dir_files'
