# ── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="aussiegeek-custom"

# ── Plugins ───────────────────────────────────────────────────────────────────
# Note : zsh-syntax-highlighting doit toujours être en dernier
# Note : pas de history-substring-search — atuin gère ^R et les flèches
plugins=(
  git
  docker
  docker-compose
  npm
  node
  python
  pip
  sudo
  z
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ── PATH ──────────────────────────────────────────────────────────────────────
# Binaires installés sans sudo (eza, fd, fzf...) : ~/.local/bin prioritaire
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
typeset -U path PATH

# ── Langue & format horaire ───────────────────────────────────────────────────
# LC_TIME=C.UTF-8 : format 24h neutre, disponible partout (évite l'AM/PM)
export LANG=fr_FR.UTF-8
export LC_ALL=fr_FR.UTF-8
export LC_TIME=C.UTF-8

# ── Historique ────────────────────────────────────────────────────────────────
HISTSIZE=20000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS    # pas de doublons consécutifs
setopt HIST_IGNORE_SPACE   # exclure les commandes précédées d'un espace
setopt SHARE_HISTORY       # partager l'historique entre sessions

# ── Comportement ──────────────────────────────────────────────────────────────
setopt AUTO_CD             # taper un dossier = cd automatique
setopt CORRECT             # correction automatique des typos

# ── Couleur autosuggestions ───────────────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"

# ── Éditeur ───────────────────────────────────────────────────────────────────
export EDITOR='vim'
command -v nvim >/dev/null 2>&1 && export EDITOR='nvim'

# ── Fichiers custom partagés + locaux ─────────────────────────────────────────
for _zsh_file in \
  "$ZSH_CUSTOM/fzf.zsh" \
  "$ZSH_CUSTOM/aliases/default.zsh" \
  "$ZSH_CUSTOM/aliases/local.zsh" \
  "$ZSH_CUSTOM/macros/default.zsh" \
  "$ZSH_CUSTOM/macros/local.zsh"; do
  [[ -f "$_zsh_file" ]] && source "$_zsh_file"
done
unset _zsh_file

# ── Overrides locaux (exports propres à la machine) ───────────────────────────
[[ -f "$ZSH_CUSTOM/export.zsh" ]] && source "$ZSH_CUSTOM/export.zsh"

# ── Atuin (après export.zsh : permet TERMINAL_DISABLE_ATUIN / ATUIN_*) ────────
# Doit rester APRÈS le chargement d'oh-my-zsh et de fzf.zsh pour que son
# bindkey ^R écrase celui du plugin fzf.
[[ -f "$ZSH_CUSTOM/atuin.zsh" ]] && source "$ZSH_CUSTOM/atuin.zsh"

# ── Auto-update (après export.zsh pour respecter les réglages TERMINAL_*) ─────
[[ -f "$ZSH_CUSTOM/update.zsh" ]] && source "$ZSH_CUSTOM/update.zsh"
typeset -f _term_update_check >/dev/null && _term_update_check

# ── Customs ───────────────────────────────────────────────────────────────────
export VIRTUAL_ENV_DISABLE_PROMPT=1

# ── Autres ────────────────────────────────────────────────────────────────────

