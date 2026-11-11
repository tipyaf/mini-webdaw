# Phase 2 — Comptes, projets partagés, analyse musicale (plus tard)

Consigné le 11 nov. 2026. **Mis de côté** : rien ne démarre avant une décision explicite de Yannick.
Ce document garde les décisions déjà prises et les pistes à étudier.

## Décisions déjà prises

- **Comptes utilisateurs** : création de compte + connexion. Plus de clé dans le lien.
- Deux façons de se connecter : **e-mail + mot de passe** (mot de passe haché, argon2id) et **Google**.
- **Pas de Meta / Facebook** (app Meta, politique de confidentialité, procédure de suppression et revue :
  trop lourd pour le besoin).
- **Back-office** réservé au rôle admin (Yannick).
- Les liens à envoyer (WhatsApp) restent possibles : Yannick fait des copier-coller.
- Le choix des technos se fera par une analyse dédiée ; passer le front en Next.js (ou autre cadre) est
  accepté si l'app grossit.

## À trancher le moment venu

1. **Qui peut entrer** : « tout le monde ne peut pas y aller ». Options :
   - inscription libre puis compte **en attente** jusqu'à validation par l'admin (recommandé) ;
   - inscription seulement avec un lien d'invitation ;
   - liste d'e-mails / comptes Google autorisés.
2. **E-mails** (vérification d'adresse, mot de passe oublié) : DuckDNS ne permet pas de déclarer SPF /
   DKIM, donc les e-mails partiraient d'un domaine tiers et finiraient souvent en indésirables. Options :
   - l'admin génère un lien de réinitialisation dans le back-office et l'envoie par WhatsApp (aucun e-mail) ;
   - acheter un domaine (~10 €/an) et un service d'envoi gratuit (Brevo, Resend).
3. **Technos** (voir plus bas).
4. Sort de l'ancienne clé partagée : durée pendant laquelle elle reste acceptée.

## Vision fonctionnelle

- **Projets** : un morceau + ses pistes + réglages du mix (volumes, mute/solo, transposition, boucles,
  marqueurs), sauvegardés sur le serveur et retrouvés sur tous les appareils.
- **Partage** : partager un projet avec une personne ou un **groupe** (ex. un groupe de musique).
- **Rôles** : globaux (admin, membre) et par projet (propriétaire, éditeur, lecteur).
- **Pistes stockées sur le serveur, une seule séparation par morceau** : clé de cache = identifiant
  YouTube, ou empreinte SHA-256 du fichier importé, + version du modèle. Un morceau déjà séparé par
  quelqu'un est servi aussitôt aux suivants (gain de minutes de calcul).
  - Volume : 6 pistes AAC ≈ 25 Mo pour 4 min → ~1 000 morceaux ≈ 25 Go.
  - Oracle Always Free : 200 Go de disques au total (dont le disque de démarrage) et un stockage objet
    gratuit d'environ 20 Go : à vérifier au moment de l'étude.
  - Quotas par utilisateur, purge des morceaux plus utilisés.
- **Analyse musicale** (voir section suivante) : tempo, tonalité, accords, paroles, grille d'accords.

## Accords, paroles, tablatures : faisabilité

**Faisable avec une bonne qualité : une grille « paroles + accords »** (comme Chordify ou Moises),
calculée automatiquement après la séparation, puis corrigeable à la main.

| Étape | Outils libres existants | Entrée | Qualité attendue |
|-------|-------------------------|--------|------------------|
| Tempo, temps, mesures | `beat_this` (CPJKU, 2024), `madmom` | mix | bonne |
| Tonalité | `essentia` (KeyExtractor), `madmom` | mix | bonne |
| Accords | `madmom` (CNN + CRF), Chordino (`chord-extractor`), BTC (transformer) | mix ou pistes sans batterie ni chant | correcte sur pop / rock / variété ; moins bonne sur jazz et accords enrichis |
| Paroles synchronisées | **LRCLIB** (base libre de paroles horodatées, API gratuite), sinon transcription Whisper (`faster-whisper`, `WhisperX` pour l'alignement mot à mot) | piste **Chant** séparée | LRCLIB : très bonne si le titre y est ; Whisper : bonne sur voix claire, à relire |
| Placement des accords sur les paroles | code maison : chaque accord est rattaché au mot chanté au même instant | sorties ci-dessus | — |
| Diagrammes d'accords (doigtés guitare / ukulélé / piano) | dictionnaire d'accords (ex. `chords-db`) | noms d'accords | exacte |

**Difficile : la vraie tablature note à note** (corde + case pour chaque note de la piste Guitare).
Possible avec une transcription en notes (`basic-pitch` de Spotify, `YourMT3+`) puis un algorithme qui
choisit corde et case ; résultat approximatif, utile comme brouillon seulement.

Technique : **Python, pas JavaScript** (les modèles et bibliothèques sont en Python, comme le séparateur
Demucs). Un service « analyseur » sur le même modèle que `separateur` : file d'attente, un morceau à la
fois, sur processeur. La VM suffit : quelques minutes de calcul par morceau (Whisper en int8 sur
processeur ARM), résultat mis en cache comme les pistes.

À vérifier : licences des modèles (`madmom` : modèles en licence non commerciale, ce qui convient à un
usage entre amis ; Chordino : GPL ; Whisper : MIT ; `basic-pitch` : Apache 2.0).

## Technos à comparer lors de l'analyse

Le cœur de l'app reste dans le navigateur (AudioWorklet, WebGPU, IndexedDB) : le rendu côté serveur
apporte peu à cette partie ; un cadre aide surtout pour les nombreux écrans à venir (connexion, projets,
partage, back-office).

| Couche | Options |
|--------|---------|
| Front | garder une page sans build / SPA Vite + React ou Svelte / Next.js (sortie `standalone` dans Dokploy) |
| API + comptes | AdonisJS 6 (auth, Lucid, hash, Ally pour Google) / NestJS / Next.js (routes API) + Better Auth / étendre le relais Hono |
| Base | PostgreSQL (Dokploy en un clic, sauvegardes) — justifiée dès qu'il y a projets, partages et groupes |
| Fichiers | disque de la VM (volume) ou stockage objet Oracle (compatible S3) |
| Calcul audio | services Python : `separateur` (existant), `analyseur` (accords, paroles, tempo) |
| Relais YouTube | inchangé (Hono + yt-dlp + WARP) |

## Découpage prévu (quand la phase 2 sera lancée)

1. Analyse des besoins détaillée + choix des technos (document de décision).
2. Contrat d'API et schéma de base.
3. En parallèle : API + comptes ; front (connexion, projets, back-office) ; ops (base, sauvegardes,
   préproduction `mini-webdaw-staging.yalab.duckdns.org`).
4. Revue de sécurité, puis matrice de tests (`03-tests.md`) sur préproduction, puis production.
5. Ensuite seulement : stockage serveur des pistes, partage, puis analyse musicale.
