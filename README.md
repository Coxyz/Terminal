# Terminal

Configuration **zsh portable** (Linux / macOS, sans `sudo`) : un seul profil
partagé entre toutes tes machines, qui s'installe et se **met à jour
automatiquement** (façon oh-my-zsh).

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/Coxyz/Terminal/main/install.sh | bash
```

L'installeur :
- installe **Oh My Zsh**, les plugins (`zsh-autosuggestions`,
  `zsh-syntax-highlighting`), **fzf**, **fd**, **eza**, **bat** et **atuin**
  (binaire pré-compilé dans `~/.local/bin` si pas de gestionnaire de paquets) ;
- déploie les fichiers de config partagés ;
- recharge le shell automatiquement (`exec zsh`) à la fin.

Il ne montre **que les actions réellement effectuées** : relancé sur une machine
déjà à jour, il affiche simplement `✅ Déjà à jour — rien à faire`.
Mets `TERMINAL_VERBOSE=true` pour tout revoir.

## Mise à jour

Au démarrage d'un shell, un check throttlé (≈1×/jour) compare le dernier commit
`main` à la version installée. Si une nouvelle version existe, le shell propose :

```
[terminal] Nouvelle version dispo (a1b2c3d).
          Mettre à jour maintenant ? [y/N]
```

`y` lance la mise à jour puis recharge le shell. Tu peux aussi la déclencher à la
main avec **`zsh-update`**.

## Structure

```
install.sh                     installeur / updater
zsh/
  .zshrc                       config principale (déployée en ~/.zshrc)
  aliases/default.zsh          alias partagés (ls→eza, git, ...)
  aliases/local.zsh            alias propres à la machine (jamais écrasé)
  macros/default.zsh           fonctions partagées (mkcd, extract, gac, ...)
  macros/local.zsh             fonctions propres à la machine (jamais écrasé)
  export.zsh                   variables d'env locales (jamais écrasé)
  fzf.zsh                      configuration fzf
  atuin.zsh                    intégration atuin (historique synchronisé)
  atuin/config.toml            config client atuin (→ ~/.config/atuin/)
  update.zsh                   auto-update
  aussiegeek-custom.zsh-theme  thème du prompt
```

Les fichiers `*/local.zsh` et `export.zsh` te sont réservés : ils sont créés une
fois puis **jamais écrasés** par les mises à jour. Mets-y tes personnalisations.

## Listing avec eza

| Commande | Effet |
|----------|-------|
| `ls`     | grille courte (équivalent du `ls` de base) |
| `l`      | liste longue, sans fichiers cachés |
| `ll`     | liste longue, avec fichiers cachés |
| `la`     | grille avec fichiers cachés |
| `lt`     | arborescence (2 niveaux) |

Repli automatique sur le vrai `ls` si `eza` n'est pas installé.

## Historique synchronisé (atuin)

`atuin` remplace **Ctrl+R** par une recherche plein écran dans un historique
partagé entre toutes les machines, avec le contexte de chaque commande (durée,
code de retour, répertoire, hôte). Serveur : `https://atuin.coxyz.fr`.

L'installeur pose une **version épinglée** du client (alignée sur le serveur).
Atuin remplace aussi la **flèche haut** — le plugin `history-substring-search` a
donc été retiré. `?` reste un caractère normal (mode IA d'atuin désactivé).

| Touche | Portée de la recherche |
|--------|------------------------|
| `Ctrl+R` | historique **global** (toutes les machines) |
| `↑` | historique de **cette machine** uniquement |

### Connexion

L'installeur la propose directement :

```
  Serveur : https://atuin.coxyz.fr
    [1] J'ai déjà un compte  → login (demande la clé de chiffrement)
    [2] Créer un compte      → register (1re machine uniquement)
    [3] Plus tard
```

C'est **atuin** qui pose les questions et masque la saisie — aucun identifiant
ne transite par le script, ni par les arguments de commande. L'étape est
ignorée si tu es déjà connecté. Après connexion, l'installeur enchaîne sur
`atuin import auto` puis `atuin sync`.

Sur la **première machine** (option 2), la clé de chiffrement est affichée une
fois : **sauvegarde-la immédiatement dans Bitwarden**. Le chiffrement est de
bout en bout — sans elle, l'historique synchronisé est irrécupérable, même avec
un accès au serveur et à sa base. Tu peux la réafficher avec `atuin key`.

Sur les **machines suivantes** (option 1), cette même clé est demandée : sans
elle, atuin créerait un second historique chiffré différemment.

Pour faire la connexion à la main, ou plus tard :

```sh
atuin login       # ou : atuin register
atuin import auto && atuin sync
```

Pour que l'installeur ne pose pas la question (machine partagée, CI) :

```sh
TERMINAL_SKIP_ATUIN_LOGIN=true bash -c "$(curl -fsSL …/install.sh)"
```

### Aliases

| Commande | Effet |
|----------|-------|
| `hs`     | recherche interactive (équivalent Ctrl+R) |
| `hsync`  | synchronisation manuelle immédiate |
| `hstat`  | serveur, compte, nb d'entrées local / distant |

### Commandes non enregistrées

`history_filter` dans `atuin/config.toml` exclut de l'historique les commandes
sans valeur de rappel : listing (`ls`, `l`, `ll`, `la`, `lt`), navigation
(`cd`, `z`), `clear`/`cls`/`pwd`/`exit`/`reload`, les alias atuin eux-mêmes et
les raccourcis `zsh-*`. Une dernière règle écarte les commandes contenant
visiblement un secret (`export *TOKEN=`, `--password=`) — utile puisque
l'historique part sur le serveur.

⚠️ Les regex atuin sont **non ancrées** : le motif `l` filtrerait tout ce qui
contient un « l ». Toujours écrire `^…$`, et vérifier après coup avec
`atuin search "<commande>"` qu'on n'a pas fait disparaître autre chose.

Le filtre ne s'applique qu'à **l'écriture** : les commandes déjà enregistrées
restent en base. Pour en purger une : `atuin history prune`.

### Personnalisation

`~/.config/atuin/config.toml` est un fichier **partagé, réécrit à chaque mise à
jour**. Pour un réglage propre à une machine, exporte la variable `ATUIN_*`
correspondante dans `export.zsh` — elle a la priorité sur le fichier :

```sh
export ATUIN_FILTER_MODE="host"              # Ctrl+R limité à cette machine
export ATUIN_FILTER_MODE_SHELL_UP_KEY_BINDING="global"   # ↑ global aussi
export ATUIN_DB_PATH="/tmp/atuin-$UID/history.db"
```

> Le second cas est utile sur un `$HOME` monté en **NFS** (postes 42) : SQLite
> supporte mal NFS et peut renvoyer `database is locked`. La base locale est
> alors perdue au reboot, mais `atuin sync` la reconstruit depuis le serveur.
> La clé et la session restent, elles, dans `~/.local/share/atuin`.

Pour désactiver atuin sur une machine, dans `export.zsh` :

```sh
export TERMINAL_DISABLE_ATUIN=true
```

## Réglages (dans `export.zsh`)

| Variable | Défaut | Rôle |
|----------|--------|------|
| `TERMINAL_REPO` | `Coxyz/Terminal` | dépôt suivi pour les MAJ |
| `TERMINAL_UPDATE_INTERVAL_DAYS` | `1` | jours entre deux checks (`0` = à chaque shell) |
| `TERMINAL_DISABLE_AUTO_UPDATE` | `false` | `true` désactive l'auto-update |
| `TERMINAL_NO_AUTO_EXEC` | `0` | `1` désactive le `exec zsh` auto après install |
| `TERMINAL_VERBOSE` | `false` | `true` affiche aussi les « déjà à jour » |
| `TERMINAL_DISABLE_ATUIN` | `false` | `true` désactive l'intégration atuin |
| `TERMINAL_SKIP_ATUIN_LOGIN` | `false` | `true` : l'installeur ne propose pas la connexion atuin |
