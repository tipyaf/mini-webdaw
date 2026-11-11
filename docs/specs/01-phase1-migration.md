# Phase 1 — Front sur Oracle, une seule adresse, clé seule dans le lien

Consigné le 11 nov. 2026. Dépôt public : aucun secret dans ce dossier.

## But

Même app, mêmes fonctions qu'aujourd'hui sur GitHub Pages, servie depuis la VM Oracle par Dokploy,
déployée automatiquement à chaque push sur `main`.

- Adresse unique : **https://mini-webdaw.yalab.duckdns.org**
- Lien d'invitation : `https://mini-webdaw.yalab.duckdns.org/#cle=<ACCESS_KEY>` (plus de `relais=`)
- Le relais répond sur la même adresse, sous `/api/*` : la page n'a plus à connaître son adresse.

## Ce qui ne change pas

- L'app reste un seul `index.html` sans build.
- Le choix « relais ou pas » existe déjà et reste le même :
  - recherche et audio YouTube → relais ;
  - séparation dans le navigateur sur ordinateur avec WebGPU et ≥ 4 Go → sinon séparation serveur ;
  - import d'un fichier sur ordinateur WebGPU → aucun appel au relais.
- Clé partagée + Turnstile + session de 1 h côté relais (la phase 2 remplacera la clé).
- Hostinger reste intact jusqu'à son arrêt (fin déc. 2026, hors de ce projet).

## Architecture cible

```
navigateur ──https──► Traefik (Dokploy, VM Oracle)
   Host(mini-webdaw.yalab.duckdns.org) && PathPrefix(/api)   → relais:8787     (priorité 100)
   Host(mini-webdaw.yalab.duckdns.org)                       → front:8080      (nginx, fichiers statiques)
   Host(mini-webdaw-relay.yalab.duckdns.org) && PathPrefix(/api) → relais:8787 (gardé pour les anciens liens)
   http → https (redirect-to-https@file)
```

## Lot A — Infra (dépôts `multipiste` + `mini-webdaw-relais` + VM)

### A1. Conteneur du front (dépôt `multipiste`, nouveaux fichiers seulement)

- `Dockerfile` : `nginxinc/nginx-unprivileged:<version>-alpine` (multi-arch, utilisateur non root, port 8080).
  Copie **uniquement** `index.html` (et favicon s'il y en a un). Jamais `lab/`, `specs/`, `DOC.md`, `.git`.
- `.dockerignore` : tout exclure sauf ce qui est copié.
- `nginx.conf` :
  - `etag on` (la bannière « Recharger » compare l'ETag) ; `Cache-Control: no-cache` sur `index.html` ;
  - `try_files $uri /index.html` inutile (une page) : 404 pour le reste ;
  - en-têtes : `Strict-Transport-Security: max-age=31536000`, `X-Content-Type-Options: nosniff`,
    `Referrer-Policy: strict-origin-when-cross-origin` (l'aperçu YouTube exige un référent),
    `Permissions-Policy` minimal, `X-Frame-Options: DENY` ;
  - CSP en **Report-Only** pendant la phase 1 (aucune casse possible), à passer en bloquant une fois la
    matrice de tests propre. Sources à autoriser (vérifier dans le code) : scripts `cdn.jsdelivr.net`,
    `challenges.cloudflare.com`, `'unsafe-inline'`, `'wasm-unsafe-eval'` ; workers `blob:` `'self'` ;
    connect `'self'` `cdn.jsdelivr.net` `huggingface.co` + hôtes de redirection HF (`*.hf.co`,
    `cas-bridge.xethub.hf.co`) ; frames `challenges.cloudflare.com` `www.youtube-nocookie.com` ;
    images `'self'` `i.ytimg.com` `data:` `blob:` ; média `blob:` `'self'`.
  - Pas de COOP/COEP (Pages n'en a pas ; COEP casserait Turnstile et l'aperçu YouTube).
- `compose.dokploy.yaml` (même modèle que le relais) : service `front`, `build: .`, `read_only: true`,
  tmpfs pour `/tmp` et le cache nginx, `cap_drop: [ALL]`, `no-new-privileges`, `mem_limit: 64m`,
  réseau `dokploy-network`, labels Traefik (router `webdaw-front` Host seul, websecure, letsencrypt ;
  router http → `redirect-to-https@file`).
- `compose.local.yaml` : pile de test locale identique à la prod (front nginx + proxy `/api` vers le
  relais lancé en local), pour tester la même origine sans Oracle. Port 8765 (déjà dans les origines
  autorisées du relais).

### A2. Relais (dépôt `mini-webdaw-relais`)

- Router `webdaw-relay` : `(Host(mini-webdaw-relay…) || Host(mini-webdaw…)) && PathPrefix(/api)`,
  `priority=100` explicite (doit passer devant le router du front).
- Variables (dans `compose.dokploy.yaml`, pas dans le fichier de secrets) :
  - `ALLOWED_ORIGINS: https://mini-webdaw.yalab.duckdns.org,https://tipyaf.github.io`
  - `TURNSTILE_HOSTNAMES: mini-webdaw.yalab.duckdns.org,tipyaf.github.io`
- **Action Yannick** : tableau de bord Cloudflare → Turnstile → widget → ajouter le nom d'hôte
  `mini-webdaw.yalab.duckdns.org`.
- Le push sur `main` du relais redéploie (webhook existant). Vérifier ensuite que l'ancien lien marche encore.

### A3. Dokploy + webhook

- Nouveau projet Dokploy « mini-webdaw », service **Compose**, source Git HTTPS publique
  `https://github.com/tipyaf/mini-webdaw.git` (pas de clé de déploiement : dépôt public), fichier
  `compose.dokploy.yaml`.
- **Branche de déploiement** : `phase1` pendant la mise au point (l'adresse n'est connue de personne,
  aucun risque), puis `main` au basculement.
- Webhook GitHub du dépôt `mini-webdaw` → `https://deploy.yalab.duckdns.org/api/deploy/compose/<jeton>`
  (la route Traefik existante l'accepte déjà : POST, IP GitHub). Secret du webhook si Dokploy le gère.
- Ne **jamais** donner de domaine au panel Dokploy.

### A4. GitHub

- Seul `tipyaf` a le droit d'écrire (vérifié : aucun autre collaborateur). Ajouter un **ruleset** sur
  `main` : interdire force-push et suppression. Pas de PR obligatoire (Yannick pousse directement).
- GitHub Pages : voir lot C (à faire **avant** de fusionner la phase 1 dans `main`, sinon Pages publie
  la nouvelle version).

## Lot B — Code du front (`index.html` seulement)

### B1. Relais = même origine

Règle de résolution de l'adresse du relais, dans l'ordre :

1. page servie en `http://localhost` / `127.0.0.1` (dev) : paramètre `relais=` du lien s'il existe,
   sinon `location.origin` (cas `compose.local.yaml`) ;
2. page servie en `https:` hors `tipyaf.github.io` : **toujours `location.origin`** ; un éventuel
   `relais=` dans un ancien lien est ignoré ;
3. `tipyaf.github.io` (copie figée, lot C) : comportement actuel inchangé.

Plus aucune adresse de relais en dur ni stockée sur la nouvelle origine.

### B2. Lien d'invitation = clé seule

- Format canonique `#cle=<clé>`. Les anciens liens `#relais=…&cle=…` restent acceptés (clé reprise,
  `relais` ignoré) et la barre d'adresse est réécrite au format canonique (`history.replaceState`),
  puisqu'elle sert de favori.
- Champ « colle le lien d'invitation » : accepte les deux formats, ou la clé nue.
- Stockage : `localStorage` ne garde que la clé (`mwd.cle`) ; lire l'ancien `mwd.relais` une fois pour
  reprendre la clé puis le supprimer.
- Textes : « Oublier ce relais » → « Oublier la clé » ; messages `noInvite` / `relay.state === 'none'`
  sans parler d'adresse de serveur.
- Bannière de mise à jour : le rechargement garde `#cle=…` (déjà le cas via `location.href`).

### B3. Réception de la bibliothèque (déménagement depuis GitHub Pages)

Les morceaux sont dans IndexedDB, liée à l'origine : sans transfert, chacun perdrait sa bibliothèque.

Protocole `postMessage` (fixé ici pour que les lots B et C avancent en parallèle) :

1. L'ancienne page ouvre `https://mini-webdaw.yalab.duckdns.org/#demenagement` avec `window.open`
   (sans `noopener`).
2. La nouvelle page, si `#demenagement` et `window.opener` : envoie
   `{ type: 'mwd-move-ready', version: 1 }` à `window.opener` avec `targetOrigin` = `https://tipyaf.github.io`.
3. L'ancienne page envoie, avec `targetOrigin` = `https://mini-webdaw.yalab.duckdns.org` :
   - `{ type: 'mwd-move-key', cle }` si elle a une clé ;
   - pour chaque morceau : `{ type: 'mwd-move-song', index, total, meta, tracks: [{ name, blob }…] }`
     (Blobs passés par clonage structuré, un morceau à la fois) ;
   - `{ type: 'mwd-move-done', total }`.
4. La nouvelle page **vérifie `event.origin === 'https://tipyaf.github.io'`**, valide la forme et la
   taille de chaque message, écrit dans IndexedDB (ignore un morceau déjà présent : même id), répond
   `{ type: 'mwd-move-ack', index }` ; l'ancienne attend l'ack avant le morceau suivant.
5. Affichage : progression « Transfert 3/12… », puis « Bibliothèque transférée » ; la nouvelle page
   retire `#demenagement` de l'adresse et garde `#cle=…`.
6. Échec ou navigateur qui coupe `opener` : message clair ; l'ancienne bibliothèque n'est jamais effacée.

La forme exacte de `meta` = celle stockée aujourd'hui dans IndexedDB (`mini-webdaw`, version 1).

## Lot C — Copie figée sur GitHub Pages (branche `gh-pages`)

- Créer `gh-pages` depuis `main` **avant** la fusion de la phase 1, régler Pages sur cette branche.
- Ajouter une bannière permanente : « mini webdaw déménage : [Ouvrir la nouvelle adresse et y transférer
  ma bibliothèque] ». Le bouton joue l'émetteur du protocole B3. Si la bibliothèque est vide : simple
  ouverture de la nouvelle adresse avec `#cle=` repris.
- L'ancienne copie reste fonctionnelle (relais Oracle via `mini-webdaw-relay…`) pendant la transition.
- Plus tard (décision Yannick, ~fin janvier) : remplacer `gh-pages` par une page de redirection qui
  garde la clé.

## Lot D — Tests (avant toute fusion dans `main`)

Matrice : voir `03-tests.md`. Ordre : local (`compose.local.yaml`) → Oracle sur la branche `phase1`
→ basculement.

## Basculement (fait par la session principale, avec l'accord de Yannick)

1. Lot C en ligne (Pages sur `gh-pages`, bannière active).
2. Fusion `phase1` → `main`, Dokploy passe sur la branche `main`, push → déploiement auto vérifié.
3. Nouveau lien envoyé aux amis : `https://mini-webdaw.yalab.duckdns.org/#cle=…`.
4. CSP passée en bloquant après une semaine sans rapport de violation.

## Critères d'acceptation

- `https://mini-webdaw.yalab.duckdns.org/#cle=…` : toutes les lignes de la matrice OK.
- Un push sur `main` met le site à jour sans action manuelle (< 3 min).
- Ancien lien GitHub Pages : toujours utilisable, et transfert de bibliothèque réussi sur Chrome,
  Safari macOS, Safari iOS, Firefox.
- `/lab/`, `/specs/`, `/DOC.md`, `/.git/` → 404 ; `http://` → redirection `https://` ; seul `/api/*`
  atteint le relais ; panel Dokploy toujours fermé de l'extérieur.
