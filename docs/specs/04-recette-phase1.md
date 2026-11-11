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

## Anomalies

| # | Plateforme | Étape | Ce qui se passe | Capture |
|---|-----------|-------|-----------------|---------|
| | | | | |
