# Shell Configuration Testing Guide

This document provides comprehensive testing procedures for bash and zsh configurations managed by chezmoi.

## Overview

Our shell configuration consists of modular, templated components:

```
Shell Configurations:
├── dot_bashrc.tmpl              # Main bash configuration
├── dot_zshrc.tmpl               # Main zsh configuration
├── .chezmoitemplates/
│   ├── shell_common.tmpl        # Shared bash/zsh configuration
│   └── ubuntu_bashrc.tmpl       # Ubuntu default bash configuration
├── dot_bash/                    # Bash-specific modules
│   ├── aliases.d/
│   ├── completion.d/
│   ├── functions.d/
│   └── keybindings.d/
└── dot_zsh/                     # Zsh-specific modules
    ├── aliases.d/
    ├── completion.d/
    ├── functions.d/
    └── keybindings.d/
```

## Testing Methodology

### 1. Pre-Testing Setup

Before testing, ensure the latest configuration is applied:

```bash
# Apply latest chezmoi configuration
chezmoi apply

# Verify no syntax errors in templates
chezmoi execute-template ~/.local/share/chezmoi/dot_bashrc.tmpl > /dev/null
chezmoi execute-template ~/.local/share/chezmoi/dot_zshrc.tmpl > /dev/null
```

### 2. Bash Configuration Testing

#### Basic Functionality Test

**Interactive Mode Test:**
```bash
# Test with fresh interactive session
bash --rcfile ~/.bashrc -i -c "
echo 'Bash Configuration Test:'
echo 'SHELL_TYPE: ' \$SHELL_TYPE
echo 'CONFIG_DIR: ' \$CONFIG_DIR
echo 'EDITOR: ' \$EDITOR
echo 'Test completed successfully'
"
```

**Non-Interactive Mode Test:**
```bash
# Test sourcing in current session
bash -c "
source ~/.bashrc
echo 'Non-interactive test:'
echo 'SHELL_TYPE: ' \$SHELL_TYPE
echo 'Basic aliases work: '
type ll 2>/dev/null && echo 'OK' || echo 'FAIL'
"
```

#### Function and Alias Testing

```bash
# Test shared functions
bash --rcfile ~/.bashrc -i -c "
echo 'Function Tests:'
type add_to_path && echo 'add_to_path: OK' || echo 'add_to_path: FAIL'
type mkcd && echo 'mkcd: OK' || echo 'mkcd: FAIL'
type extract && echo 'extract: OK' || echo 'extract: FAIL'
"

# Test Ubuntu default aliases  
bash --rcfile ~/.bashrc -i -c "
echo 'Ubuntu Alias Tests:'
type ll && echo 'll: OK' || echo 'll: FAIL'
type la && echo 'la: OK' || echo 'la: FAIL'
alias | grep -q 'grep.*color' && echo 'colored grep: OK' || echo 'colored grep: FAIL'
"

# Test shared aliases
bash --rcfile ~/.bashrc -i -c "
echo 'Shared Alias Tests:'
alias | grep -q 'g=.git.' && echo 'git aliases: OK' || echo 'git aliases: FAIL'
alias | grep -q 'gs=.git status.' && echo 'git status alias: OK' || echo 'git status alias: FAIL'
"
```

#### Module Loading Test

```bash
# Test modular configuration loading
bash --rcfile ~/.bashrc -i -c "
echo 'Module Loading Test:'
echo 'CONFIG_DIR: ' \$CONFIG_DIR
[[ -d \$CONFIG_DIR ]] && echo 'Config directory exists: OK' || echo 'Config directory: FAIL'

# Test that modular loading is working
if [[ -d \$CONFIG_DIR/aliases.d ]]; then
    echo 'Bash modules directory found: OK'
else
    echo 'Bash modules directory: FAIL'
fi
"
```

#### PATH Management Test

```bash
# Test PATH deduplication
bash --rcfile ~/.bashrc -i -c "
echo 'PATH Management Test:'
original_path_count=\$(echo \$PATH | tr ':' '\n' | wc -l)
add_to_path '/tmp/test_path_duplicate'
add_to_path '/tmp/test_path_duplicate'  # Add same path twice
new_path_count=\$(echo \$PATH | tr ':' '\n' | wc -l)
expected_count=\$((original_path_count + 1))
if [[ \$new_path_count -eq \$expected_count ]]; then
    echo 'PATH deduplication: OK'
else
    echo 'PATH deduplication: FAIL (expected \$expected_count, got \$new_path_count)'
fi
"
```

### 3. Zsh Configuration Testing

#### Basic Functionality Test

**Interactive Mode Test:**
```bash
# Test with fresh interactive session
zsh -c "
source ~/.zshrc
echo 'Zsh Configuration Test:'
echo 'SHELL_TYPE: ' \$SHELL_TYPE
echo 'CONFIG_DIR: ' \$CONFIG_DIR
echo 'EDITOR: ' \$EDITOR
echo 'Test completed successfully'
"
```

#### Zsh-Specific Features Test

```bash
# Test zsh options
zsh -c "
source ~/.zshrc
echo 'Zsh Options Test:'
setopt | grep -q AUTO_CD && echo 'AUTO_CD: OK' || echo 'AUTO_CD: FAIL'
setopt | grep -q AUTO_PUSHD && echo 'AUTO_PUSHD: OK' || echo 'AUTO_PUSHD: FAIL'
setopt | grep -q SHARE_HISTORY && echo 'SHARE_HISTORY: OK' || echo 'SHARE_HISTORY: FAIL'
"

# Test zsh functions
zsh -c "
source ~/.zshrc
echo 'Zsh Function Tests:'
type work && echo 'work function: OK' || echo 'work function: FAIL'
type bookmark && echo 'bookmark function: OK' || echo 'bookmark function: FAIL'
type goto && echo 'goto function: OK' || echo 'goto function: FAIL'
"

# Test zsh aliases
zsh -c "
source ~/.zshrc
echo 'Zsh Alias Tests:'
alias | grep -q 'zshreload' && echo 'zshreload: OK' || echo 'zshreload: FAIL'
alias | grep -q 'h=.*history' && echo 'history alias: OK' || echo 'history alias: FAIL'
"
```

### 4. Cross-Shell Compatibility Testing

#### Shared Configuration Test

```bash
# Test that shared configuration works in both shells
echo "=== Cross-Shell Compatibility Test ==="

# Test bash
echo "Testing shared config in bash:"
bash --rcfile ~/.bashrc -i -c "
type mkcd >/dev/null && echo 'mkcd in bash: OK' || echo 'mkcd in bash: FAIL'
[[ \$EDITOR == 'nvim' ]] && echo 'EDITOR in bash: OK' || echo 'EDITOR in bash: FAIL'
"

# Test zsh  
echo "Testing shared config in zsh:"
zsh -c "
source ~/.zshrc
type mkcd >/dev/null && echo 'mkcd in zsh: OK' || echo 'mkcd in zsh: FAIL'
[[ \$EDITOR == 'nvim' ]] && echo 'EDITOR in zsh: OK' || echo 'EDITOR in zsh: FAIL'
"
```

#### PATH Consistency Test

```bash
# Test PATH management consistency
echo "=== PATH Consistency Test ==="

bash --rcfile ~/.bashrc -i -c "
echo 'Bash PATH entries:'
echo \$PATH | tr ':' '\n' | grep -E '(\.local/bin|bin)$' | head -3
"

zsh -c "
source ~/.zshrc
echo 'Zsh PATH entries:'
echo \$PATH | tr ':' '\n' | grep -E '(\.local/bin|bin)$' | head -3
"
```

### 5. Template Testing

#### Template Syntax Validation

```bash
# Test template syntax without applying
echo "=== Template Syntax Test ==="

# Test each template individually
chezmoi execute-template ~/.local/share/chezmoi/dot_bashrc.tmpl > /tmp/bashrc_test 2>&1
if [[ $? -eq 0 ]]; then
    echo "bashrc template syntax: OK"
else
    echo "bashrc template syntax: FAIL"
    cat /tmp/bashrc_test
fi

chezmoi execute-template ~/.local/share/chezmoi/dot_zshrc.tmpl > /tmp/zshrc_test 2>&1
if [[ $? -eq 0 ]]; then
    echo "zshrc template syntax: OK"
else
    echo "zshrc template syntax: FAIL"
    cat /tmp/zshrc_test
fi

# Test shared templates
chezmoi execute-template ~/.local/share/chezmoi/.chezmoitemplates/shell_common.tmpl > /tmp/shell_common_test 2>&1
if [[ $? -eq 0 ]]; then
    echo "shell_common template syntax: OK"
else
    echo "shell_common template syntax: FAIL"
    cat /tmp/shell_common_test
fi
```

#### OS-Specific Template Testing

```bash
# Test OS-specific template branches
echo "=== OS-Specific Template Test ==="
echo "Current OS: $(chezmoi data | grep '"os"' | awk '{print $2}' | tr -d ',"')"

# Test that OS-specific sections are included
if grep -q "chezmoi.os" ~/.bashrc; then
    echo "OS-specific configuration applied: OK"
else
    echo "OS-specific configuration applied: FAIL"
fi
```

### 6. Performance Testing

#### Load Time Testing

```bash
# Test configuration load time
echo "=== Performance Test ==="

# Bash load time
bash_time=$(time (bash --rcfile ~/.bashrc -i -c "exit" 2>/dev/null) 2>&1 | grep real | awk '{print $2}')
echo "Bash config load time: $bash_time"

# Zsh load time  
zsh_time=$(time (zsh -c "source ~/.zshrc && exit" 2>/dev/null) 2>&1 | grep real | awk '{print $2}')
echo "Zsh config load time: $zsh_time"
```

### 7. Regression Testing

#### Complete Test Suite

```bash
#!/bin/bash
# Complete shell configuration test suite

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
        return 0
    else
        echo "❌ FAIL"
        return 1
    fi
}

# Initialize counters
passed=0
failed=0

# Template syntax tests
run_test "bashrc template syntax" "chezmoi execute-template ~/.local/share/chezmoi/dot_bashrc.tmpl" && ((passed++)) || ((failed++))
run_test "zshrc template syntax" "chezmoi execute-template ~/.local/share/chezmoi/dot_zshrc.tmpl" && ((passed++)) || ((failed++))

# Bash functionality tests
run_test "bash basic loading" "bash --rcfile ~/.bashrc -i -c 'exit'" && ((passed++)) || ((failed++))
run_test "bash shell detection" "bash --rcfile ~/.bashrc -i -c '[[ \$SHELL_TYPE == \"bash\" ]]'" && ((passed++)) || ((failed++))
run_test "bash add_to_path function" "bash --rcfile ~/.bashrc -i -c 'type add_to_path'" && ((passed++)) || ((failed++))
run_test "bash shared functions" "bash --rcfile ~/.bashrc -i -c 'type mkcd && type extract'" && ((passed++)) || ((failed++))

# Zsh functionality tests  
run_test "zsh basic loading" "zsh -c 'source ~/.zshrc'" && ((passed++)) || ((failed++))
run_test "zsh shell detection" "zsh -c 'source ~/.zshrc && [[ \$SHELL_TYPE == \"zsh\" ]]'" && ((passed++)) || ((failed++))
run_test "zsh shared functions" "zsh -c 'source ~/.zshrc && type mkcd && type extract'" && ((passed++)) || ((failed++))
run_test "zsh specific functions" "zsh -c 'source ~/.zshrc && type work && type bookmark'" && ((passed++)) || ((failed++))

# Cross-shell consistency tests
run_test "environment variable consistency" "bash --rcfile ~/.bashrc -i -c '[[ \$EDITOR == \"nvim\" ]]' && zsh -c 'source ~/.zshrc && [[ \$EDITOR == \"nvim\" ]]'" && ((passed++)) || ((failed++))

echo
echo "=== Test Results ==="
echo "✅ Passed: $passed"
echo "❌ Failed: $failed"
echo "Total: $((passed + failed))"

if [[ $failed -eq 0 ]]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed. Please review the configuration."
    exit 1
fi
```

## Troubleshooting

### Common Issues

1. **"function not found" errors**
   - Check if shared template is being loaded
   - Verify CONFIG_DIR is set correctly
   - Ensure modular files exist in correct directories

2. **PATH duplication**
   - Test add_to_path function manually
   - Check if function is defined before use
   - Verify PATH before and after configuration load

3. **Template syntax errors**
   - Use `chezmoi execute-template` to test individual templates
   - Check for missing template variables
   - Verify conditional logic syntax

4. **Cross-platform issues**
   - Test OS detection: `echo $OSTYPE` and `chezmoi data`
   - Verify OS-specific template branches
   - Check platform-specific commands exist

### Debug Mode

For detailed debugging, use:

```bash
# Debug bash configuration
bash -x ~/.bashrc

# Debug zsh configuration  
zsh -x ~/.zshrc

# Debug chezmoi template execution
chezmoi execute-template --debug
```

## Automation

### CI/CD Integration

For automated testing in CI/CD pipelines:

```yaml
# Example GitHub Actions test
- name: Test Shell Configurations
  run: |
    chezmoi apply
    bash docs/shell-testing-guide.md  # Run test suite
    echo "Shell configuration tests completed"
```

### Git Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Test shell configurations before commit
if ! bash /path/to/shell-test-suite.sh; then
    echo "Shell configuration tests failed!"
    exit 1
fi
```

## Best Practices

1. **Regular Testing**: Run tests after any configuration changes
2. **Cross-Platform Testing**: Test on different OS when possible  
3. **Performance Monitoring**: Track load time changes
4. **Documentation**: Update this guide when adding new features
5. **Modular Testing**: Test individual components separately

---

*Last updated: $(date)*
*Chezmoi version: $(chezmoi --version | head -1)*