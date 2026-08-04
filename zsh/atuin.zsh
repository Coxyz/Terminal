# =============================================================================
# atuin.zsh — Historique shell synchronisé (serveur : atuin.coxyz.fr)
# =============================================================================
# Sourcé APRÈS export.zsh : tu peux donc désactiver atuin ou surcharger sa
# config par machine depuis export.zsh (voir le README).

# ── Garde-fous ────────────────────────────────────────────────────────────────
[[ "${TERMINAL_DISABLE_ATUIN:-false}" == "true" ]] && return
command -v atuin >/dev/null 2>&1 || return

# ── Initialisation ────────────────────────────────────────────────────────────
# Atuin prend ^R ET la flèche haut (plugin history-substring-search retiré
# de .zshrc en conséquence).
#   ^R          → recherche globale, toutes machines (filter_mode)
#   flèche haut → recherche limitée à cette machine
#                 (filter_mode_shell_up_key_binding dans config.toml)
# --disable-ai : sans ça, un `?` en début de ligne ouvre le mode IA d'atuin
#                au lieu d'insérer le caractère.
# L'init passe après oh-my-zsh, donc son bindkey ^R gagne sur le plugin fzf.
eval "$(atuin init zsh --disable-ai)"

# ── Aliases ───────────────────────────────────────────────────────────────────
alias hs='atuin search -i'    # recherche interactive sans passer par ^R
alias hsync='atuin sync'      # sync manuelle immédiate
alias hstat='atuin status'    # serveur, compte, nb d'entrées local/distant
