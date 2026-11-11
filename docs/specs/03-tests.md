# Matrice de tests (phase 1, reprise en phase 2)

Règle : rien n'est fusionné dans `main` tant qu'une case « indispensable » est rouge.

## Plateformes

| Code | Plateforme | Moyen |
|------|-----------|-------|
| CH | Chrome macOS | navigateur Claude in Chrome / Playwright Chromium |
| SF | Safari macOS | Playwright WebKit + contrôle manuel final de Yannick |
| FF | Firefox macOS | Playwright Firefox |
| IP | Safari iPadOS | simulateur iPad (voir mémoire « Test Safari iPad ») |
| IH | Safari iOS iPhone | simulateur iPhone |
| AN | Chrome Android | appareil de Yannick (aucun émulateur ici) |

## Fonctions (toutes indispensables sauf mention)

| # | Fonction | CH | SF | FF | IP | IH | AN |
|---|----------|----|----|----|----|----|----|
| F1 | Ouverture via `#cle=…`, clé gardée après rechargement | | | | | | |
| F2 | Ancien lien `#relais=…&cle=…` accepté et réécrit en `#cle=…` | | | | | | |
| F3 | Choisir un dossier mp3 (sur ordinateur) | | | | – | – | – |
| F4 | Lecture multipiste synchro, mute / solo / volume dB | | | | | | |
| F5 | Boucle A-B, transposition, limiteur | | | | | | |
| F6 | Recherche YouTube (Turnstile invisible, session) | | | | | | |
| F7 | Aperçu YouTube (youtube-nocookie) | | | | | | |
| F8 | Import YouTube → séparation navigateur (WebGPU) | | si WebGPU | si WebGPU | – | – | – |
| F9 | Import YouTube → séparation serveur 6 pistes | forcé `?serveur` | | | | | |
| F10 | Import d'un fichier audio → séparation | | | | | | |
| F11 | Bibliothèque : persiste après rechargement, suppression | | | | | | |
| F12 | Bannière « Recharger » après un nouveau déploiement | | | | | | |
| F13 | Sans clé : message d'invitation, fichiers locaux OK sur ordinateur WebGPU | | | | | | |
| F14 | Transfert de bibliothèque depuis `tipyaf.github.io` | | | | | | |
| F15 | Console sans erreur ; aucun rapport CSP inattendu | | | | | | |

## Sécurité / exploitation (une fois, depuis le Mac)

- S1 `curl -I http://…` → 301/308 vers https ; HSTS présent.
- S2 `/lab/`, `/specs/`, `/DOC.md`, `/.git/HEAD`, `/compose.dokploy.yaml` → 404.
- S3 `/api/health` sans session → 401 ; Origin étrangère → 403.
- S4 port 3000 fermé de l'extérieur ; aucune route vers le panel Dokploy.
- S5 push d'un commit anodin sur la branche suivie → nouveau déploiement < 3 min, ETag changé.
- S6 ancien hôte `mini-webdaw-relay.yalab.duckdns.org/api/health` répond toujours (anciens liens).
- S7 en-têtes de sécurité présents (`curl -I`), CSP Report-Only sans violation sur F1–F14.
