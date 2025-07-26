#!/bin/bash

# Custom key bindings for bash readline

# Ctrl+O: Execute current command and bring next history item to prompt
bind '"\C-o": operate-and-get-next'

# Ctrl+K: Kill (delete) from cursor to end of line  
bind '"\C-k": kill-line'
