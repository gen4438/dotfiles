# 参考: /usr/share/byobu/keybindings/f-keys.tmux

unbind-key -n C-b
bind-key -n M-C-F11 break-pane

bind-key -n C-F3 display-panes \; swap-pane -s :. -t :.- \; select-pane -t :.
bind-key -n C-F4 display-panes \; swap-pane -s :. -t :.+ \; select-pane -t :.

set -g prefix F12
unbind-key -n C-a
