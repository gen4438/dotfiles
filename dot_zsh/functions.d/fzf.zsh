#!/bin/zsh

# FZF functions with lazy loading for performance
# Heavy functions are loaded only when first used

# Initialize lazy loading helper
_fzf_lazy_init() {
    # Mark as initialized to avoid recursive loading
    export _FZF_FUNCTIONS_LOADED=1
}

# Check if we should use lazy loading
if [[ -z "$_FZF_FUNCTIONS_LOADED" ]]; then
    # Create lazy loading wrappers for heavy functions
    for func in fssh fpyenv fpyenv-virtualenv fconda fda fds fdrm fdrmi fdrmv fdr fk cdwt fgbr fgco fgco_preview fgcoc; do
        eval "$func() { 
            unset -f $func
            _fzf_lazy_init
            source \$0
            $func \"\$@\"
        }"
    done
    return 0
fi

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
  docker rmi $(awk '{print $3}' <<<"$target")
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

_my_gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

_my_gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##' |
  tr '\n' ' '
}

_my_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

_my_gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

_my_gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

_my_gs() {
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


# # キーバインド
# # 参考: ~/.fzf/shell/key-bindings.zsh
# if [[ $- =~ i ]]; then
#   # Required to refresh the prompt after fzf
#   bindkey -m emacs-standard '"\er": redraw-current-line'

#   bindkey -m vi-command '"\C-z": emacs-editing-mode'
#   bindkey -m vi-insert '"\C-z": emacs-editing-mode'
#   bindkey -m emacs-standard '"\C-z": vi-editing-mode'

#   bindkey -m emacs-standard '"\C-g\C-f": " \C-b\C-k \C-u`_my_gf`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
#   bindkey -m emacs-standard '"\C-g\C-b": " \C-b\C-k \C-u`_my_gb`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
#   bindkey -m emacs-standard '"\C-g\C-t": " \C-b\C-k \C-u`_my_gt`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
#   bindkey -m emacs-standard '"\C-g\C-h": " \C-b\C-k \C-u`_my_gh`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
#   bindkey -m emacs-standard '"\C-g\C-r": " \C-b\C-k \C-u`_my_gr`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
#   bindkey -m emacs-standard '"\C-g\C-s": " \C-b\C-k \C-u`_my_gs`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'

#   bindkey -m vi-command '"\C-g\C-f": "\C-z\C-g\C-f\C-z"'
#   bindkey -m vi-command '"\C-g\C-b": "\C-z\C-g\C-b\C-z"'
#   bindkey -m vi-command '"\C-g\C-t": "\C-z\C-g\C-t\C-z"'
#   bindkey -m vi-command '"\C-g\C-h": "\C-z\C-g\C-h\C-z"'
#   bindkey -m vi-command '"\C-g\C-r": "\C-z\C-g\C-r\C-z"'
#   bindkey -m vi-command '"\C-g\C-s": "\C-z\C-g\C-s\C-z"'

#   bindkey -m vi-insert '"\C-g\C-f": "\C-z\C-g\C-f\C-z"'
#   bindkey -m vi-insert '"\C-g\C-b": "\C-z\C-g\C-b\C-z"'
#   bindkey -m vi-insert '"\C-g\C-t": "\C-z\C-g\C-t\C-z"'
#   bindkey -m vi-insert '"\C-g\C-h": "\C-z\C-g\C-h\C-z"'
#   bindkey -m vi-insert '"\C-g\C-r": "\C-z\C-g\C-r\C-z"'
#   bindkey -m vi-insert '"\C-g\C-s": "\C-z\C-g\C-s\C-z"'
# fi

