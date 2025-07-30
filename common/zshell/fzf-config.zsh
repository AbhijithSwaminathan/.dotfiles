# FZF Configuration
# Advanced fuzzy finder setup with enhanced previews and completion

# =============================================================================
# FZF Default Options and Theme
# =============================================================================

export FZF_DEFAULT_OPTS=" \
 --color=bg:#051519,fg:#b8b1a9,hl:#1a8d63\
 --color=bg+:#3d3d3d,fg+:#b8b1a9,hl+:#2fc859\
 --color=info:#39a7a2,border:#8ed0ce,prompt:#92d3a2\
 --color=pointer:#051519,marker:#fb3d66,spinner:#fb3d66,header:#f8818e\
 --height=40%\
 --layout=reverse\
 --border\
 --margin=1\
 --padding=1"

# =============================================================================
# FZF Command Configurations
# =============================================================================

# Default command for finding files
if command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fdfind --hidden --strip-cwd-prefix --exclude .git --exclude node_modules'
else
    export FZF_DEFAULT_COMMAND='find . -type f 2>/dev/null | grep -v -E "(\.git/|node_modules/)"'
fi

# Ctrl+T: Find files
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
else
    export FZF_CTRL_T_OPTS="--preview 'head -50 {}'"
fi

# Alt+C: Change directory
if command -v fdfind >/dev/null 2>&1; then
    export FZF_ALT_C_COMMAND='fdfind --type d --hidden --strip-cwd-prefix --exclude .git --exclude node_modules'
else
    export FZF_ALT_C_COMMAND='find . -type d 2>/dev/null | grep -v -E "(\.git/|node_modules/)"'
fi

if command -v eza >/dev/null 2>&1; then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=always {} | head -200'"
else
    export FZF_ALT_C_OPTS="--preview 'ls -la {}'"
fi

# =============================================================================
# FZF Completion Functions
# =============================================================================

# Generate paths for completion (files and directories)
_fzf_compgen_path() {
    local base_dir="${1:-.}"
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --hidden --follow --exclude .git --exclude node_modules . "$base_dir" 2>/dev/null
    else
        find "$base_dir" -type f 2>/dev/null | grep -v -E '(\.git/|node_modules/)'
    fi
}

# Generate directories for completion
_fzf_compgen_dir() {
    local base_dir="${1:-.}"
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type d --hidden --follow --exclude .git --exclude node_modules . "$base_dir" 2>/dev/null
    else
        find "$base_dir" -type d 2>/dev/null | grep -v -E '(\.git/|node_modules/)'
    fi
}

# =============================================================================
# FZF Preview Functions
# =============================================================================

# Enhanced preview function with better error handling and more contexts
_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        # Directory navigation with enhanced preview
        cd)
            fzf --preview '
                dir={}
                if [[ -d "$dir" ]]; then
                    echo "📁 Directory: $dir"
                    echo "─────────────────────────"
                    if command -v eza >/dev/null 2>&1; then
                        eza --tree --color=always --icons=always --level=2 "$dir" 2>/dev/null | head -30
                    else
                        ls -la "$dir" 2>/dev/null | head -20
                    fi
                    echo
                    echo "📊 Directory Stats:"
                    echo "Files: $(find "$dir" -type f 2>/dev/null | wc -l)"
                    echo "Dirs:  $(find "$dir" -type d 2>/dev/null | wc -l)"
                    echo "Size:  $(du -sh "$dir" 2>/dev/null | cut -f1)"
                else
                    echo "❌ Not a directory: $dir"
                fi
            ' --preview-window 'right:60%:wrap' "$@"
            ;;
        
        # Environment variables
        export|unset)
            fzf --preview 'eval "echo \${}"' \
                --preview-window 'down:3:wrap' \
                "$@"
            ;;
        
        # SSH hosts with network info
        ssh)
            fzf --preview '
                host={}
                echo "🌐 SSH Host: $host"
                echo "─────────────────────────"
                if command -v dig >/dev/null 2>&1; then
                    dig +short "$host" 2>/dev/null | head -5
                fi
                if command -v ping >/dev/null 2>&1; then
                    echo
                    echo "🏓 Connectivity:"
                    timeout 2 ping -c 1 "$host" >/dev/null 2>&1 && echo "✅ Reachable" || echo "❌ Unreachable"
                fi
            ' --preview-window 'right:50%:wrap' "$@"
            ;;
        
        # Git operations
        git)
            fzf --preview '
                item={}
                echo "🔀 Git: $item"
                echo "─────────────────────────"
                if [[ -f "$item" ]]; then
                    git status --porcelain "$item" 2>/dev/null
                    echo
                    git diff --color=always "$item" 2>/dev/null | head -50
                else
                    echo "$item"
                fi
            ' --preview-window 'right:60%:wrap' "$@"
            ;;
        
        # Process management
        kill|ps)
            fzf --preview 'ps -p {} -o pid,ppid,user,comm,args' \
                --preview-window 'down:5:wrap' \
                "$@"
            ;;
        
        # Package management
        apt|dpkg)
            fzf --preview 'apt show {} 2>/dev/null || dpkg -l | grep {}' \
                --preview-window 'right:60%:wrap' \
                "$@"
            ;;
        
        # Default: file content with syntax highlighting
        *)
            fzf --preview '
                file={}
                if [[ -f "$file" ]]; then
                    echo "📄 File: $(basename "$file")"
                    echo "📍 Path: $file"
                    echo "📊 Size: $(du -h "$file" 2>/dev/null | cut -f1)"
                    echo "🕒 Modified: $(stat -c %y "$file" 2>/dev/null | cut -d. -f1)"
                    echo "─────────────────────────"
                    
                    mime_type=$(file --mime-type -b "$file" 2>/dev/null)
                    case "$mime_type" in
                        text/*|application/json|application/xml)
                            if command -v bat >/dev/null 2>&1; then
                                bat -n --color=always --line-range :200 "$file" 2>/dev/null
                            else
                                head -50 "$file" 2>/dev/null
                            fi
                            ;;
                        image/*)
                            echo "🖼️  Image file - $(identify "$file" 2>/dev/null || echo "Image details unavailable")"
                            ;;
                        application/pdf)
                            echo "📕 PDF file - Use '"'"'pdftotext'"'"' or '"'"'xdg-open'"'"' to view"
                            ;;
                        *)
                            echo "📋 Binary file - Type: $mime_type"
                            file "$file" 2>/dev/null
                            ;;
                    esac
                elif [[ -d "$file" ]]; then
                    echo "📁 Directory: $file"
                    echo "─────────────────────────"
                    if command -v eza >/dev/null 2>&1; then
                        eza --tree --color=always --icons=always --level=2 "$file" 2>/dev/null | head -30
                    else
                        ls -la "$file" 2>/dev/null | head -20
                    fi
                    echo
                    echo "📊 Directory Stats:"
                    echo "Files: $(find "$file" -type f 2>/dev/null | wc -l)"
                    echo "Dirs:  $(find "$file" -type d 2>/dev/null | wc -l)"
                    echo "Size:  $(du -sh "$file" 2>/dev/null | cut -f1)"
                else
                    echo "❓ Unknown file type: $file"
                fi
            ' --preview-window 'right:60%:wrap' "$@"
            ;;
    esac
}

# =============================================================================
# FZF Integration with Other Tools
# =============================================================================

# Enhanced fzf-git integration
if [[ -f "$HOME/.config/fzf-git.sh/fzf-git.sh" ]]; then
    source "$HOME/.config/fzf-git.sh/fzf-git.sh"
fi

# Custom key bindings
if command -v fzf >/dev/null 2>&1; then
    # Ctrl+R: Enhanced history search
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    
    # Alt+E: Environment variables
    bindkey -s '^[e' 'export | fzf --preview "eval echo \\\${}" | cut -d= -f1^M'
fi

# =============================================================================
# Function Verification
# =============================================================================

# Verify that essential functions are loaded
if command -v fzf >/dev/null 2>&1; then
    # Only check if the main completion functions exist
    if ! type "_fzf_compgen_path" >/dev/null 2>&1 || ! type "_fzf_compgen_dir" >/dev/null 2>&1 || ! type "_fzf_comprun" >/dev/null 2>&1; then
        echo "Warning: Some FZF functions failed to load" >&2
    fi
fi
