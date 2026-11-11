# Roadmap — mini webdaw sur Oracle

Consigné le 11 nov. 2026. Specs : `01-phase1-migration.md`, `02-phase2-vision.md`, `03-tests.md`.
Dépôt public : aucun secret dans ce dossier.

**En cours : phase 1 seulement.** La phase 2 (comptes, base de données, projets partagés…) est mise de
côté ; sa vision et les décisions déjà prises sont dans `02-phase2-vision.md`.

Objectif de la phase 1 : toutes les fonctions de l'app marchent comme sur GitHub Pages, sur téléphone,
tablette et ordinateur (iOS, Android, Chrome, Safari, Firefox), à l'adresse
https://mini-webdaw.yalab.duckdns.org, avec un lien `#cle=…` seul, et un déploiement automatique à
chaque push sur `main`.

## Vue d'ensemble

```
  [A infra]  ──┐
  [B front]  ──┼─► intégration (branche phase1) ─► revue sécu ─► [D tests local + Oracle] ─► basculement (main)
  [C Pages]  ──┘
```

A, B et C ne touchent pas les mêmes fichiers et partagent un protocole déjà fixé (spec 01, B3) :
ils avancent en même temps.

## Sessions et sous-agents

| Lot | Où | Modèle / effort | Pourquoi ce choix | Branche / fichiers |
|-----|----|-----------------|-------------------|--------------------|
| A — Infra front + relais + Dokploy + GitHub | session, worktree | **Opus 5.5 / medium** | VM en production et sécurité : jugement sur des pièges déjà rencontrés (Dokploy, Traefik) ; peu de code | `multipiste` : `Dockerfile`, `.dockerignore`, `nginx.conf`, `compose.dokploy.yaml`, `compose.local.yaml` (branche `phase1-infra`) ; `mini-webdaw-relais` : `compose.dokploy.yaml` ; VM |
| B — Code du front (B1–B3) | session, worktree | **Sonnet 5.5 / high** | code ciblé dans un gros fichier unique, spec précise | `multipiste/index.html` (branche `phase1-front`) |
| C — Copie figée Pages + émetteur | session, worktree | **Sonnet 5.5 / medium** | petit lot, protocole déjà écrit | branche `gh-pages` (nouvelle) |
| Intégration | session principale | — | fusion `phase1-infra` + `phase1-front` → `phase1` | — |
| Revue de sécurité | sous-agent | Opus 5.5 / high | relit le diff complet (en-têtes, CSP, `postMessage`, routage) | lecture seule |
| D — Tests | session principale + sous-agents navigateurs | Sonnet 5.5 / medium | répétitif, outillé (simulateurs, Playwright) | aucun fichier |
| Basculement | session principale | — | gestes en production, avec l'accord de Yannick | — |

Règles communes aux sessions :

- Lire les specs de ce dossier et la mémoire « URLs projets Oracle ».
- Ne jamais pousser sur `main` du front sans l'accord de Yannick. Le relais (lot A) peut être poussé :
  le changement reste compatible avec l'existant.
- Ne jamais saisir de secret dans l'interface Dokploy ; ne jamais donner de domaine au panel.
- Tunnel SSH vers le panel : `ssh -N -i ~/.ssh/oracle_ed25519 -L 127.0.0.1:3000:127.0.0.1:3000 ubuntu@mini-webdaw-relay.yalab.duckdns.org`.

## Actions de Yannick

| Quand | Action |
|-------|--------|
| Lot A | Ajouter `mini-webdaw.yalab.duckdns.org` au widget Turnstile (Cloudflare) |
| Tests | Contrôle sur son téléphone Android et Safari macOS |
| Basculement | Feu vert, puis envoi du nouveau lien aux amis |
