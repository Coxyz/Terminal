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
  `zsh-syntax-highlighting`), **fzf**, **fd** et **eza** (binaire pré-compilé
  dans `~/.local/bin` si pas de gestionnaire de paquets) ;
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

## Réglages (dans `export.zsh`)

| Variable | Défaut | Rôle |
|----------|--------|------|
| `TERMINAL_REPO` | `Coxyz/Terminal` | dépôt suivi pour les MAJ |
| `TERMINAL_UPDATE_INTERVAL_DAYS` | `1` | jours entre deux checks (`0` = à chaque shell) |
| `TERMINAL_DISABLE_AUTO_UPDATE` | `false` | `true` désactive l'auto-update |
| `TERMINAL_NO_AUTO_EXEC` | `0` | `1` désactive le `exec zsh` auto après install |
| `TERMINAL_VERBOSE` | `false` | `true` affiche aussi les « déjà à jour » |
