#!/bin/bash -e

PKG=byobu
. /usr/lib/byobu/include/common

CURDIR=$(tmux list-panes -F "#{pane_active} #{pane_current_path}" | grep "^1" | cut -d' ' -f2-)
BRANCH=""
if [ -e /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
    cd "$CURDIR" && BRANCH=$(__git_ps1 %s);
fi
STATUS=$(color m W; printf $BRANCH; color -)
echo $STATUS
