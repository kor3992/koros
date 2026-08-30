# ============================================================
# KorOS Fish Configuration
# ============================================================

# Run Fastfetch when opening an interactive terminal
if status is-interactive
    fastfetch
end

# Simple KorOS greeting
function fish_greeting
    echo "--------Welcome to KorOS--------"
end
