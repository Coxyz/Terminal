# =============================================================================
# aliases/default.zsh — Aliases partagés
# =============================================================================

#------- ZSH -------#
alias zsh-config='$EDITOR ~/.zshrc'
alias zsh-alias='$EDITOR $ZSH_CUSTOM/aliases/local.zsh'
alias zsh-macros='$EDITOR $ZSH_CUSTOM/macros/local.zsh'
alias zsh-export='$EDITOR $ZSH_CUSTOM/export.zsh'
# zsh-update : défini comme fonction dans update.zsh

#------- MAIN -------#
alias reload='source ~/.zshrc'
alias e='$EDITOR'

#------ LISTING ------#
# eza si disponible (https://eza.rocks), sinon repli sur ls.
#   ls → grille courte    l → liste sans cachés    ll → liste avec cachés
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --no-quotes'
  alias l='eza -lgh  --no-quotes --group-directories-first'
  alias ll='eza -lagh --no-quotes --group-directories-first'
  alias la='eza -a   --no-quotes --group-directories-first'
  alias lt='eza --tree --level=5 --no-quotes --group-directories-first'
else
  alias l='ls -lh'
  alias ll='ls -lha'
fi

#------ BAT (cat amélioré) ------#
# bat si disponible (https://github.com/sharkdp/bat), sinon repli sur cat.
# --paging=never = comportement identique à cat (pas de pager interactif).
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
fi

#------ UTILITIES ------#
alias cls='clear'
