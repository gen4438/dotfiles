#!/bin/bash
# Entrypoint script for chezmoi testing container
# This script uses environment variables from .env file to automate testing
#
# WARNING: This script is designed to run ONLY inside Docker containers.
# DO NOT run this script on your host system!

set -e

# Safety check: Ensure this script runs only inside Docker container
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then
    echo "ERROR: This script is designed to run ONLY inside Docker containers!"
    echo "Running this script on your host system may overwrite your chezmoi configuration."
    echo ""
    echo "Please use: docker compose -f compose.test-chezmoi.yml run --rm chezmoi-test"
    exit 1
fi

echo "==================================================================="
echo "Chezmoi Test Environment"
echo "==================================================================="

# Display environment variables for debugging
echo ""
echo "Environment variables:"
echo "  GIT_NAME: ${GIT_NAME}"
echo "  GIT_EMAIL: ${GIT_EMAIL}"
echo "  GITHUB_TOKEN: ${GITHUB_TOKEN:+[SET]}" # Don't print the actual token
echo ""

# Check if local source is mounted
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    echo "==================================================================="
    echo "Local chezmoi source detected"
    echo "Testing with locally mounted source directory"
    echo "==================================================================="
    echo ""

    # Create chezmoi config directory
    mkdir -p ~/.config/chezmoi

    # Pre-create chezmoi configuration to skip prompts
    echo "Creating chezmoi configuration from environment variables..."
    cat > ~/.config/chezmoi/chezmoi.toml <<EOF
encryption = "age"

[age]
    identity = "${TEST_AGE_IDENTITY:-~/.config/chezmoi/key.txt}"
    recipient = "${TEST_AGE_RECIPIENT:-age1lnt3hvd436d02uaen8nelcn6aywephrx7lx6ctxjyeyqwv82x59s8kk7dx}"

[data.git]
    name = "${GIT_NAME}"
    email = "${GIT_EMAIL}"

[data]
    ssh_identity_file = "${TEST_SSH_IDENTITY_FILE:-}"
EOF

    echo "Configuration created successfully."
    echo ""

    # Apply local chezmoi configuration
    echo "Applying local chezmoi configuration..."
    # Exclude encrypted files since we don't have the age key in test environment
    # Note: Some onchange scripts may fail in test environment, but that's expected
    chezmoi apply --exclude encrypted || {
        echo ""
        echo "⚠️  Warning: Some scripts failed, but basic setup completed."
        echo "This is normal in test environment (missing development tools, etc.)"
        echo ""
    }

    echo ""
    echo "==================================================================="
    echo "✅ Chezmoi configuration applied!"
    echo "==================================================================="
    echo ""
    echo "You can now:"
    echo "  - Run 'chezmoi verify' to verify the installation"
    echo "  - Run 'chezmoi diff' to see differences"
    echo "  - Run 'chezmoi apply' to re-apply after making changes"
    echo "  - Explore the applied configuration"
    echo ""

    # Start interactive shell for further testing
    exec /bin/bash
else
    echo "==================================================================="
    echo "ERROR: Local chezmoi source not found"
    echo "==================================================================="
    echo ""
    echo "Expected to find .git directory at:"
    echo "  $HOME/.local/share/chezmoi/.git"
    echo ""
    echo "Please ensure you're running this with the local source mounted:"
    echo "  docker compose -f compose.test-chezmoi.yml run --rm chezmoi-test"
    echo ""
    exit 1
fi
