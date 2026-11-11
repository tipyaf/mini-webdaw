# Recette manuelle — phase 1

Site testé : `https://mini-webdaw.yalab.duckdns.org/#cle=<clé>` (le lien complet est donné à part,
jamais écrit dans ce dépôt public). Branche déployée : `phase1`.

**Prérequis** : `mini-webdaw.yalab.duckdns.org` ajouté aux noms d'hôte du widget Turnstile (Cloudflare),
sinon la recherche échoue (« Vérification anti-robot échouée »).

Cocher par plateforme : **CH** Chrome Mac · **SF** Safari Mac · **FF** Firefox Mac · **IP** iPad ·
**IH** iPhone · **AN** Android Chrome. « – » = sans objet.

## 1. Lien et clé

| # | Geste | Attendu | CH | SF | FF | IP | IH | AN |
|---|-------|---------|----|----|----|----|----|----|
| 1.1 | Ouvrir le lien `#cle=…` | l'app s'ouvre, pas de message « lien d'invitation » | | | | | | |
| 1.2 | Recharger la page | toujours connecté, `#cle=…` toujours dans l'adresse | | | | | | |
| 1.3 | Ouvrir l'ancien lien `#relais=https://mini-webdaw-relay.yalab.duckdns.org&cle=…` sur la nouvelle adresse | adresse réécrite en `#cle=…`, tout marche | | | | | | |
| 1.4 | Ouvrir `https://mini-webdaw.yalab.duckdns.org/` sans clé (navigation privée) | message demandant le lien ; champ « coller » accepte le lien ou la clé nue | | | | | | |
| 1.5 | « Oublier la clé » puis recharger sans `#cle` | redemande le lien | | | | | | |

## 2. Lecteur (sur un morceau de la bibliothèque ou un dossier mp3)

| # | Geste | Attendu | CH | SF | FF | IP | IH | AN |
|---|-------|---------|----|----|----|----|----|----|
| 2.1 | « Choisir le dossier mp3… » | les chansons du dossier apparaissent | | | | – | – | – |
| 2.2 | Lecture, pause, déplacement dans le morceau | pistes synchro, pas de décrochage | | | | | | |
| 2.3 | Mute / solo / volume dB | effet immédiat sur la bonne piste | | | | | | |
| 2.4 | Boucle A-B | boucle propre | | | | | | |
| 2.5 | Transposition ± | hauteur change, tempo conservé | | | | | | |
| 2.6 | Limiteur | pas de saturation | | | | | | |

## 3. Nouveau morceau

| # | Geste | Attendu | CH | SF | FF | IP | IH | AN |
|---|-------|---------|----|----|----|----|----|----|
| 3.1 | Recherche YouTube (ex. « Daniela Elmer Food Beat ») | résultats avec vignettes | | | | | | |
| 3.2 | Aperçu d'un résultat | la vidéo se lit dans la page | | | | | | |
| 3.3 | Importer → séparation | 6 pistes rangées dans la bibliothèque (ordinateur WebGPU : dans le navigateur ; mobile : sur le serveur, ~5 min) | | | | | | |
| 3.4 | Coller une URL YouTube → « Afficher » | même chose qu'une recherche | | | | | | |
| 3.5 | Importer un fichier audio | 6 pistes rangées | | | | | | |
| 3.6 | Ordinateur : forcer le serveur avec `?serveur` avant le `#` | séparation faite par le serveur | | – | – | – | – | – |

## 4. Bibliothèque et mises à jour

| # | Geste | Attendu | CH | SF | FF | IP | IH | AN |
|---|-------|---------|----|----|----|----|----|----|
| 4.1 | Recharger après un import | le morceau est toujours là et se lit | | | | | | |
| 4.2 | Supprimer un morceau | il disparaît, confirmation demandée | | | | | | |
| 4.3 | Laisser l'onglet ouvert pendant un déploiement (Claude pousse un commit sur `phase1`), revenir sur l'onglet | bandeau « Recharger » ; après clic, `#cle=…` conservé | | | | | | |

## 5. Transfert depuis GitHub Pages (au basculement seulement)

Testable seulement quand GitHub Pages publiera la branche `gh-pages` (première étape du basculement).
La bibliothèque de l'ancienne adresse n'est jamais effacée : en cas d'échec, rien n'est perdu.

| # | Geste | Attendu | CH | SF | FF | IP | IH | AN |
|---|-------|---------|----|----|----|----|----|----|
| 5.1 | Sur `tipyaf.github.io/mini-webdaw`, bouton du bandeau « déménage » | nouvelle adresse ouverte, « Transfert n/N », puis « Bibliothèque transférée » | | | | | | |
| 5.2 | Sur la nouvelle adresse | morceaux transférés lisibles, clé reprise (pas de lien à recoller) | | | | | | |

## Résultats de la recette faite par Claude (11 nov. 2026, branche `phase1`, commit 45ab2ae)

Moyens : Chrome Mac (Claude in Chrome), simulateurs iPad Pro 13 et iPhone 18 Pro (vrai Safari iOS),
Playwright Firefox et WebKit (moteur de Safari Mac). Turnstile refuse les navigateurs pilotés par
Playwright Firefox (code 600010) : le parcours Firefox complet a été fait sur la pile locale
`compose.local.yaml` (même image du front, relais local sans Turnstile).

| Étape | CH | IP | IH | FF (local) | WebKit Mac |
|-------|----|----|----|------------|------------|
| 1.1 lien `#cle=` | ✅ | ✅ | ✅ | ✅ | ✅ |
| 1.2 rechargement | ✅ | ✅ | – | ✅ | – |
| 1.3 ancien lien réécrit | ✅ | – | – | ✅ | ✅ |
| 1.4 sans clé + clé nue collée | ✅ | – | – | – | – |
| 1.5 oublier la clé | ✅ | – | – | – | – |
| 2.1 dossier mp3 | ✅ | – | – | – | – |
| 2.2–2.6 lecture, mute, solo, boucle, transposition, limiteur | ✅ | ✅ (lecture, mute, transposition) | ✅ (lecture) | ✅ (lecture) | – |
| 3.1 recherche | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3.2 aperçu YouTube | ✅ | – | – | – | – |
| 3.3 import YouTube | ✅ navigateur | ✅ serveur | ✅ serveur | ✅ navigateur (WebGPU) | voir anomalie A1 |
| 3.5 import fichier | ✅ navigateur | – | – | – | – |
| 3.6 `?serveur` (fichier) | ✅ | – | – | – | – |
| 4.1 bibliothèque après rechargement | ✅ | ✅ | – | ✅ | – |
| 4.2 suppression | ✅ | – | – | – | – |
| 4.3 bannière « Recharger » | ✅ | ✅ | – | – | – |
| Console | aucune erreur | – | – | aucune erreur | – |

Corrigé pendant la recette : durée « 0:00 » d'un fichier séparé sur le serveur (défaut déjà présent
sur GitHub Pages) → commit 45ab2ae.

Non testé par Claude : Android (aucun émulateur), vrai Safari Mac et vrai Firefox avec Turnstile
(impossible à piloter), bloc 5 (transfert, seulement au basculement).

## Anomalies

| # | Plateforme | Étape | Ce qui se passe | Capture |
|---|-----------|-------|-----------------|---------|
| A1 | WebKit Mac (Playwright) | 3.3 | Séparation serveur OK, mais rangement bloqué à 90 %. Cause trouvée pour la session éphémère : WebKit y refuse de ranger un fichier dans IndexedDB (comme Safari en navigation privée) ; avec un profil normal, la sonde IndexedDB passe. Un essai avec profil normal est resté figé ; nouvel essai impossible ce soir (limite horaire de séparations du relais atteinte par les tests). Même comportement sur GitHub Pages : pas une régression. **À vérifier à la main sur le vrai Safari Mac.** | — |
| A2 | Chrome, tous | 1.3 | Coller un nouveau lien dans la barre d'adresse d'un onglet déjà ouvert ne l'applique qu'après rechargement (déjà le cas avant). | — |
| A3 | iPhone | 3.1 | Le zoom reste agrandi après la saisie dans le champ de recherche (police < 16 px) ; graduations de la frise serrées. Déjà le cas avant. | — |
| A4 | iPad, iPhone | panneau | Le pied du panneau dit « Séparation dans ce navigateur » alors que la séparation se fait sur le serveur. Déjà le cas avant. | — |
