# Neovim Update Script for Windows
# This provides the same functionality as Makefile targets for Windows users

param(
    [Parameter(Position = 0)]
    [ValidateSet("all", "plugins", "env", "lazy", "mason", "coc", "treesitter", "health", "help")]
    [string]$Target = "help"
)

function Write-Header {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "🔄 $Message" -ForegroundColor Yellow
}

function Update-NeovimLazy {
    Write-Info "Updating Lazy.nvim plugins..."
    & nvim --headless "+Lazy! sync" +qa
    Write-Success "Lazy.nvim plugins updated"
}

function Update-NeovimMason {
    Write-Info "Updating Mason LSP servers..."
    & nvim --headless "+MasonUpdate" +qa
    Write-Success "Mason LSP servers updated"
}

function Update-NeovimCoc {
    Write-Info "Updating coc.nvim extensions..."
    & nvim --headless "+CocUpdate" +qa
    Write-Success "coc.nvim extensions updated"
}

function Update-NeovimTreesitter {
    Write-Info "Updating treesitter parsers..."
    & nvim --headless "+TSUpdate" +qa
    Write-Success "treesitter parsers updated"
}

function Update-NeovimEnvironment {
    Write-Info "Updating Python/Node.js environment..."

    # Python environment update
    $pythonUpdated = $false
    if (Test-Path "$env:HOME\venv_neovim\Scripts\python.exe") {
        Write-Host "Updating venv_neovim..."
        & "$env:HOME\venv_neovim\Scripts\pip.exe" install --upgrade pip pynvim neovim
        $pythonUpdated = $true
    }
    elseif (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Host "Updating Python packages..."
        & python -m pip install --upgrade --user pynvim neovim
        $pythonUpdated = $true
    }

    if (-not $pythonUpdated) {
        Write-Host "⚠️  Python environment not found" -ForegroundColor Yellow
    }

    # Node.js environment update
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "Updating npm packages..."
        & npm update -g neovim tree-sitter-cli 2>$null
        if ($LASTEXITCODE -ne 0) {
            & npm install -g neovim tree-sitter-cli 2>$null
        }
    }
    else {
        Write-Host "⚠️  npm not found" -ForegroundColor Yellow
    }

    Write-Success "Environment updated"
}

function Invoke-NeovimHealth {
    Write-Info "Running Neovim health check..."
    & nvim --headless "+checkhealth provider" +qa 2>&1 | Select-String -Pattern "(python3|node|OK|WARNING|ERROR)"
}

function Show-Help {
    Write-Host @"
Neovim Update Script for Windows

Usage:
  .\Update-Neovim.ps1 <target>

Available targets:
  all         - Update all Neovim components (plugins + environment)
  plugins     - Update all Neovim plugins (lazy, mason, coc, treesitter)
  env         - Update Python/Node.js environment
  lazy        - Update Lazy.nvim plugins
  mason       - Update Mason LSP servers
  coc         - Update coc.nvim extensions
  treesitter  - Update treesitter parsers
  health      - Run Neovim health check
  help        - Show this help message

Examples:
  .\Update-Neovim.ps1 all        # Update everything
  .\Update-Neovim.ps1 plugins    # Update plugins only
  .\Update-Neovim.ps1 lazy       # Update Lazy.nvim only
"@
}

# Main execution
switch ($Target) {
    "all" {
        Write-Header "Updating all Neovim components..."
        Update-NeovimLazy
        Update-NeovimMason
        Update-NeovimCoc
        Update-NeovimTreesitter
        Update-NeovimEnvironment
        Write-Success "All Neovim components updated"
    }
    "plugins" {
        Write-Header "Updating all Neovim plugins..."
        Update-NeovimLazy
        Update-NeovimMason
        Update-NeovimCoc
        Update-NeovimTreesitter
        Write-Success "All Neovim plugins updated"
    }
    "env" {
        Update-NeovimEnvironment
    }
    "lazy" {
        Update-NeovimLazy
    }
    "mason" {
        Update-NeovimMason
    }
    "coc" {
        Update-NeovimCoc
    }
    "treesitter" {
        Update-NeovimTreesitter
    }
    "health" {
        Invoke-NeovimHealth
    }
    "help" {
        Show-Help
    }
}
