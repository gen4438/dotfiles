#!/bin/bash

# Core utility functions for bash environment
# Note: Specific function categories have been moved to separate files:
# - encoding.sh: URL and Unicode encoding/decoding functions
# - document.sh: Pandoc document conversion functions  
# - navigation.sh: Directory navigation utilities

# Load modular function files
_functions_dir="$(dirname "${BASH_SOURCE[0]}")"
for func_file in "$_functions_dir"/{encoding,document,navigation}.sh; do
    [[ -f "$func_file" ]] && source "$func_file"
done
unset _functions_dir func_file

# Legacy function aliases for backward compatibility
# These maintain existing function names while using the new modular structure
alias md2html='pandoc_md2html'  # Legacy alias for pandoc_md2html
