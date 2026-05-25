# =============================================================================
# update.zsh — Vérification automatique des mises à jour (façon oh-my-zsh)
#
# Au démarrage du shell, compare le dernier commit de la branche `main` du dépôt
# avec la version installée localement. Le check est :
#   - throttlé : au plus une requête réseau tous les N jours ;
#   - synchrone mais à timeout court : le prompt apparaît dans LE shell courant
#     (pas au démarrage suivant) ;
#   - persistant : tant qu'une MAJ est en attente, chaque shell la propose.
#
# Réglages — surchargeables dans export.zsh :
#   TERMINAL_REPO                  dépôt GitHub "owner/name"   (défaut : Coxyz/Terminal)
#   TERMINAL_UPDATE_INTERVAL_DAYS  jours entre deux checks      (défaut : 1 ; 0 = à chaque shell)
#   TERMINAL_DISABLE_AUTO_UPDATE   "true" pour tout désactiver  (défaut : false)
# =============================================================================

: ${TERMINAL_REPO:=Coxyz/Terminal}
: ${TERMINAL_UPDATE_INTERVAL_DAYS:=1}
: ${TERMINAL_DISABLE_AUTO_UPDATE:=false}
: ${TERMINAL_INSTALL_URL:=https://raw.githubusercontent.com/$TERMINAL_REPO/main/install.sh}

_term_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/terminal-zsh"
_term_version_file="$_term_cache_dir/version"        # SHA actuellement installé
_term_lastcheck_file="$_term_cache_dir/last_check"   # timestamp du dernier check réseau
_term_flag_file="$_term_cache_dir/update_available"  # SHA distant si une MAJ est en attente

# ── Mise à jour manuelle (réutilise l'installeur distant) ─────────────────────
zsh-update() {
  command -v curl >/dev/null 2>&1 || { print -u2 -- "curl introuvable"; return 1; }
  print -P "%F{blue}[terminal]%f Mise à jour en cours..."
  # TERMINAL_FROM_UPDATER=1 : l'installeur ne fait pas le exec lui-même, on s'en
  # charge ici pour recharger le shell courant (où la fonction tourne).
  if curl -fsSL "$TERMINAL_INSTALL_URL" | TERMINAL_FROM_UPDATER=1 bash; then
    rm -f "$_term_flag_file"
    print -P "%F{green}[terminal]%f Mise à jour terminée — rechargement du shell..."
    source ~/.zshrc
  else
    print -P "%F{red}[terminal]%f Échec de la mise à jour."
    return 1
  fi
}

# ── Check distant : throttlé + synchrone (timeout court) ───────────────────────
# Met (ou retire) le flag selon que le SHA distant diffère du SHA installé.
# Récupère le SHA via l'API GitHub (header sha = texte brut, pas de JSON).
_term_check_remote() {
  [[ "$TERMINAL_DISABLE_AUTO_UPDATE" == "true" ]] && return 0
  command -v curl >/dev/null 2>&1 || return 0
  mkdir -p "$_term_cache_dir" 2>/dev/null || return 0

  local now last interval
  now=$(date +%s)
  interval=$(( TERMINAL_UPDATE_INTERVAL_DAYS * 86400 ))
  last=0
  [[ -f "$_term_lastcheck_file" ]] && last="$(<"$_term_lastcheck_file")"
  [[ "$last" == <-> ]] || last=0
  (( now - last < interval )) && return 0   # throttle : pas de requête trop souvent

  print -r -- "$now" > "$_term_lastcheck_file"

  local remote installed
  remote="$(curl -fsSL --max-time 3 -H 'Accept: application/vnd.github.sha' \
    "https://api.github.com/repos/$TERMINAL_REPO/commits/main" 2>/dev/null)" || return 0
  [[ -n "$remote" ]] || return 0

  installed=""
  [[ -f "$_term_version_file" ]] && installed="$(<"$_term_version_file")"
  if [[ -n "$installed" && "$remote" != "$installed" ]]; then
    print -r -- "$remote" > "$_term_flag_file"
  else
    rm -f "$_term_flag_file"
  fi
}

# ── Propose la MAJ tant qu'une nouvelle version est en attente ────────────────
_term_prompt_update() {
  [[ "$TERMINAL_DISABLE_AUTO_UPDATE" == "true" ]] && return 0
  [[ -o interactive ]] || return 0
  [[ -f "$_term_flag_file" ]] || return 0
  [[ -r /dev/tty ]] || return 0   # besoin d'un vrai terminal pour le prompt

  local remote answer
  remote="$(<"$_term_flag_file")"
  print -P "%F{yellow}[terminal]%f Nouvelle version dispo (${remote[1,7]})."
  print -n -- "          Mettre à jour maintenant ? [y/N] "
  if read -q answer </dev/tty; then
    print ""
    zsh-update
  else
    print ""
  fi
}

# ── Point d'entrée ────────────────────────────────────────────────────────────
# Ce fichier ne fait que DÉFINIR des fonctions : il NE lance PAS le check au source.
# Raison : oh-my-zsh auto-source tous les $ZSH_CUSTOM/*.zsh (dont ce fichier) AVANT
# que .zshrc ne charge export.zsh, puis .zshrc le re-source. Lancer le check ici
# le ferait tourner deux fois (double prompt) et en ignorant les réglages
# TERMINAL_* de export.zsh. C'est donc .zshrc qui appelle _term_update_check, une
# seule fois, une fois export.zsh chargé.
_term_update_check() {
  _term_check_remote      # synchrone : peut poser le flag immédiatement…
  _term_prompt_update     # …que le prompt détecte aussitôt dans CE shell.
}
