#!/bin/bash

# Document conversion functions using pandoc
# Requires: pandoc, google-chrome (for PDF generation)

# Convert Markdown to HTML with GitHub styling
pandoc_md2html() {
    if ! command -v pandoc >/dev/null 2>&1; then
        echo "Error: pandoc command not found" >&2
        return 1
    fi
    
    if [[ -z "$1" ]]; then
        echo "Usage: pandoc_md2html <input.md>" >&2
        return 1
    fi
    
    local input_file="$1"
    local name=$(echo "$input_file" | sed 's/\.[^.]*$//')
    local css_path="$HOME/Sources/github-markdown-css/github-markdown.css"
    
    if [[ ! -f "$css_path" ]]; then
        echo "Warning: GitHub CSS not found at $css_path, using default styling" >&2
        pandoc "$input_file" --self-contained -o "${name}.html"
    else
        pandoc "$input_file" --self-contained -c "$css_path" -o "${name}.html"
    fi
}

# Convert Markdown to PDF via HTML
pandoc_md2pdf() {
    if ! command -v google-chrome >/dev/null 2>&1; then
        echo "Error: google-chrome command not found" >&2
        return 1
    fi
    
    if [[ -z "$1" ]]; then
        echo "Usage: pandoc_md2pdf <input.md>" >&2
        return 1
    fi
    
    # First convert to HTML
    pandoc_md2html "$1" || return 1
    
    local input_file="$1"
    local name=$(echo "$input_file" | sed 's/\.[^.]*$//')
    
    # Convert HTML to PDF using headless Chrome
    google-chrome --disable-crash-reporter --disable-gpu --headless \
        --print-to-pdf="${name}.pdf" "${name}.html"
}