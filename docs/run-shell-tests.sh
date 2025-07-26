#!/bin/bash
# Quick shell configuration test script
# Based on docs/shell-testing-guide.md

echo "=== Shell Configuration Test Suite ==="
echo "Date: $(date)"
echo "Chezmoi version: $(chezmoi --version | head -1)"
echo

# Function to run test and report result
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✅ PASS"
        ((passed_tests++))
    else
        echo "❌ FAIL"
        ((failed_tests++))
    fi
    ((total_tests++))
}

# Initialize counters
total_tests=0
passed_tests=0
failed_tests=0

# Template syntax tests
echo "--- Template Syntax Tests ---"
run_test "bashrc template syntax" "chezmoi execute-template ~/.local/share/chezmoi/dot_bashrc.tmpl"
run_test "zshrc template syntax" "chezmoi execute-template ~/.local/share/chezmoi/dot_zshrc.tmpl"
run_test "shell_common template syntax" "chezmoi execute-template ~/.local/share/chezmoi/.chezmoitemplates/shell_common.tmpl"
run_test "ubuntu_bashrc template syntax" "chezmoi execute-template ~/.local/share/chezmoi/.chezmoitemplates/ubuntu_bashrc.tmpl"

echo
echo "--- Bash Functionality Tests ---"
run_test "bash basic loading" "bash --rcfile ~/.bashrc -i -c 'exit' 2>/dev/null"
run_test "bash shell detection" "bash --rcfile ~/.bashrc -i -c '[[ \$SHELL_TYPE == \"bash\" ]]' 2>/dev/null"
run_test "bash add_to_path function" "bash --rcfile ~/.bashrc -i -c 'type add_to_path' 2>/dev/null"
run_test "bash shared functions" "bash --rcfile ~/.bashrc -i -c 'type mkcd && type extract' 2>/dev/null"
run_test "bash ubuntu aliases" "bash --rcfile ~/.bashrc -i -c 'type ll && type la' 2>/dev/null"
run_test "bash environment variables" "bash --rcfile ~/.bashrc -i -c '[[ \$EDITOR == \"nvim\" ]]' 2>/dev/null"
echo
echo "--- Zsh Functionality Tests ---"
run_test "zsh basic loading" "zsh -c 'source ~/.zshrc'"
run_test "zsh shell detection" "zsh -c 'source ~/.zshrc && [[ \$SHELL_TYPE == \"zsh\" ]]'"
run_test "zsh shared functions" "zsh -c 'source ~/.zshrc && type mkcd && type extract'"
run_test "zsh specific functions" "zsh -c 'source ~/.zshrc && type work && type bookmark'"
run_test "zsh options" "zsh -c 'source ~/.zshrc && setopt | grep -q autocd'"
echo
echo "--- Cross-Shell Consistency Tests ---"
run_test "environment variable consistency" "bash --rcfile ~/.bashrc -i -c '[[ \$EDITOR == \"nvim\" ]]' 2>/dev/null && zsh -c 'source ~/.zshrc && [[ \$EDITOR == \"nvim\" ]]'"
run_test "shared alias consistency" "bash --rcfile ~/.bashrc -i -c 'alias | grep -q \"g=.*git\"' 2>/dev/null && zsh -c 'source ~/.zshrc && alias | grep -q \"g=.*git\"'"
echo
echo "--- PATH Management Tests ---"
run_test "bash PATH deduplication" "bash --rcfile ~/.bashrc -i -c 'mkdir -p /tmp/test_path_bash; original=\$(echo \$PATH | tr \":\" \"\n\" | wc -l); add_to_path \"/tmp/test_path_bash\"; add_to_path \"/tmp/test_path_bash\"; new=\$(echo \$PATH | tr \":\" \"\n\" | wc -l); [[ \$new -eq \$((original + 1)) ]]; rm -rf /tmp/test_path_bash' 2>/dev/null"
run_test "zsh PATH deduplication" "zsh -c 'source ~/.zshrc; mkdir -p /tmp/test_path_zsh; original=\$(echo \$PATH | tr \":\" \"\n\" | wc -l); add_to_path \"/tmp/test_path_zsh\"; add_to_path \"/tmp/test_path_zsh\"; new=\$(echo \$PATH | tr \":\" \"\n\" | wc -l); [[ \$new -eq \$((original + 1)) ]]; rm -rf /tmp/test_path_zsh'"
echo
echo "=== Test Results ==="
echo "✅ Passed: $passed_tests"
echo "❌ Failed: $failed_tests"
echo "Total: $total_tests"

if [[ $failed_tests -eq 0 ]]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed. Please review the configuration."
    exit 1
fi