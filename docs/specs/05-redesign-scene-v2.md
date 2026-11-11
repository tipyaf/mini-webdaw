# 05 — Refonte du front « Scène v2 »

Consigné le 11 nov. 2026. Passation et plan des étapes : `06-handoff-redesign.md`.
Document de design validé : `../design/multipiste-scene-v2.html` (à ouvrir dans un navigateur).
Dépôt public : aucun secret dans ce dossier.

Cette spec permet de construire **exactement** ce que Yannick a validé dans le document de design, sur
ordinateur, iPad (paysage et portrait) et téléphone. Elle ne change ni l'audio, ni le relais, ni la
séparation, ni le format de la bibliothèque.

## 1. Sources de vérité et règles

| Sujet | Qui fait foi |
|-------|--------------|
| Apparence (dimensions, couleurs, rendu des composants, 3 écrans × 6 vues) | Le **document de design**. Son `<style>` (blocs préfixés `.mk`, `.b`, `.b2`, `.dsk`, `.tab`, `.pho`) est la référence : le **porter** en retirant le préfixe `.mk`, ne pas le réinventer. |
| Comportement, textes, états, accessibilité, cas non dessinés | **Cette spec**. |
| Fonctions existantes de l'app | `index.html` actuel : on ne perd aucune fonction (voir § 7). |

Si le document et la spec se contredisent sur l'apparence, le document gagne. Si une chose n'est ni dans
le document ni ici, ne pas l'inventer : la poser comme question dans la PR.

Les éléments **non dessinés** dans le document sont marqués **[spec]** dans ce texte : ce sont des
décisions prises ici, dans le langage visuel du document. Leur rendu est à faire valider par Yannick en
captures avant fusion.

Contraintes techniques (inchangées) :

- Un seul fichier `index.html`, HTML + CSS + JS inline, sans build ni dépendance nouvelle.
- La CSP du déploiement (`nginx.conf`) impose `style-src 'self' 'unsafe-inline'`, `font-src 'self'`,
  `img-src 'self' data: blob: https://i.ytimg.com`. Donc **aucune ressource externe** : ni Google Fonts, ni
  CDN d'icônes. Icônes = SVG inline (traits 2 px, arrondis, `currentColor`, comme dans le document).
- Polices : le document utilise Inter, Space Grotesk et JetBrains Mono. Dans l'app, piles système :
  `--f-ui: Inter, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif` ;
  `--f-head: "Space Grotesk", var(--f-ui)` (titres en 600) ;
  `--f-mono: "JetBrains Mono", ui-monospace, "SF Mono", Menlo, monospace`.
  Héberger les polices (`fonts/*.woff2`, même origine) est une option ultérieure : elle demande
  `Dockerfile`, `nginx.conf` et la copie `gh-pages`. Ne pas la faire dans cette refonte sans accord.
- Chiffres toujours en `font-variant-numeric: tabular-nums` (temps, dB, pourcentages).
- Thème **sombre uniquement**. Pas de thème clair.
- Une seule page, pas de défilement de la page : `height: 100dvh`, `overflow: hidden` sur `body`.

## 2. Jetons de design

À déclarer dans `:root`. Valeurs exactes du document.

### 2.1 Couleurs

| Jeton | Valeur | Usage |
|-------|--------|-------|
| `--bg` | `#0b0d10` | fond de l'app |
| `--s1` | `#15171b` | lignes de piste, dock, cartes, popovers |
| `--s2` | `#1c1f24` | champ de recherche, boutons au repos, éléments actifs de liste |
| `--s3` | `#272b32` | boutons secondaires, fonds d'icônes, cases de barre de progression |
| `--ln` | `rgba(255,255,255,.08)` | filets et bordures |
| `--tx` | `#eceef1` | texte |
| `--dim` | `#8e949e` | texte secondaire |
| `--faint` | `#5d636d` | texte tertiaire, graduations |
| `--mute` | `#ff5a5f` | bouton M actif, erreurs |
| `--solo` | `#ffcf4a` | bouton S actif (texte `#1a1400`) |
| `--ok` | `#35c48a` | étapes terminées, pastille « déjà importé » |
| `--acc` | `#c4f24a` | accent unique de l'interface |
| `--acc-ink` | `#10150a` | texte sur fond accent |
| `--rail` | `#06070a` | rail et crête des faders |
| `--cap-1..4` | `#6b707a` `#444851` `#2d3037` `#3e4249` | dégradé du capuchon |
| `--tick` | `#868c96` | graduations majeures |

Couleurs de pistes : **inchangées** (`COLORS`, `FALLBACK` dans `index.html`). L'ancien accent ambre
`#f2b33d` disparaît de l'interface ; il ne reste que comme couleur de la piste Guitare. L'accent lime ne
doit **jamais** servir à colorer une piste, un M ou un S.

Remplacements des anciens jetons : `--accent` → `--acc`, `--panel` → `--s1`, `--panel2` → `--s2`,
`--line` → `--ln`, `--text` → `--tx`, `--muted` → `--dim`, `--mute`, `--solo` : voir ci-dessus.
Erreur : fond `rgba(255,90,95,.09)`, bordure `rgba(255,90,95,.32)`, texte `#ffb0b3`, icône `#ff7a80`.
Voile : `rgba(6,7,9,.66)` (popovers) ; `rgba(9,10,12,.88)` (écran de dépôt).

### 2.2 Typographie

| Élément | Taille / graisse | Police |
|---------|------------------|--------|
| Texte courant | 13 px / 400, interligne 1.35 | UI |
| Nom de piste | 15 / 600 (téléphone 13) | UI |
| Titre de morceau (bouton du haut) | 14 / 600 | head |
| Sous-ligne (pistes · durée) | 11.5 / 400, `--dim` | UI |
| Valeur dB d'une piste | 13 / 600 (téléphone 11) | mono |
| Temps du dock | 38 / 500, `letter-spacing: -.03em` (iPad 32, téléphone 30) | mono |
| Sous-ligne du temps | 12 (téléphone 11), `--faint` | mono |
| Tonalité (valeur) | 20 / 600 (téléphone 16) | mono |
| Libellés de section | 11 / 600, majuscules, `letter-spacing: .1em` | UI |
| Champ de recherche | 15 | UI |
| Boutons | 12 à 14 / 600 | UI |
| Règle | 10.5 / 500 | mono |

### 2.3 Rayons, espacements, tailles

- Rayons : lignes de piste et cartes 14 ; boutons du haut et songbtn 14 ; champ 15 (téléphone 14) ;
  dock 24 ; feuille de recherche et popovers 16–18 ; cartes de résultat 18 ; M/S 10 (téléphone 9) ;
  capuchon 5 ; pastilles 999.
- Gouttière horizontale : 20 px (téléphone 12 px). Écart entre lignes de piste : 4 px (téléphone 2 px).
- Zone tactile minimale 44 × 44 px pour tout bouton isolé. Exceptions : M et S (42 × 36 ; téléphone
  36 × 32), espacés d'au moins 6 px.

## 3. Mises en page par taille d'écran

Le choix se fait par **largeur de fenêtre** (media queries), jamais par détection d'appareil.

| Code | Largeur | Cas typiques |
|------|---------|--------------|
| `dsk` | ≥ 1024 px | ordinateur, iPad paysage (1024, 1180, 1366) |
| `tab` | 700 à 1023 px | iPad portrait (744, 820, 834), petites fenêtres |
| `pho` | < 700 px | téléphones portrait (360, 375, 390, 412) |

`@media (min-width: 1024px)` pour `dsk`, `@media (max-width: 1023.98px)` pour `tab`,
`@media (max-width: 699.98px)` pour `pho`. Les trois partagent le **même HTML**. Les en-têtes de piste et
le dock sont des grilles qui changent de colonnes. Les seules différences de balisage sont le fader de
piste (horizontal en `dsk`/`tab`, vertical au bord droit en `pho`) et le bouton Boucle (avec libellé en
`dsk`, icône seule en `tab`/`pho`).

### 3.1 Structure commune

```
body (100dvh, flex colonne)
├─ barre du haut   (.tb)
├─ [pho seulement] ligne de recherche (.orow)
├─ zone des pistes (.body) : règle + lignes de piste + calque de boucle/tête de lecture
├─ dock de transport (.dock)
└─ calques : voile, feuille de recherche (.sheet), popovers, écran de dépôt, toasts
```

Hauteur de référence des maquettes : `dsk` 810 px, `tab` 802 px, `pho` 844 px (cadres du document).

### 3.2 Tableau des dimensions

| Élément | `dsk` | `tab` | `pho` |
|---------|-------|-------|-------|
| Barre du haut : hauteur | 68 | 68 | 56 (+ barre d'état système) |
| Barre du haut : colonnes | `300px 1fr 300px`, écart 16 | `252px 1fr auto`, écart 12 | `1fr auto auto`, écart 8 |
| Padding horizontal | 20 | 20 | 12 |
| Bouton morceau (songbtn) | 50 h, r14, `--s2` | idem | 46 h |
| Pochette dans songbtn | 40 × 40 | 40 × 40 | 40 × 40 |
| Champ de recherche | 50 h, max 540, centré | 50 h | 48 h, ligne dédiée, padding `0 12 8` |
| Bouton fichier dans le champ | 34 × 34, r10 | 34 × 34 | 38 × 38, r11 |
| Jeton d'import | 32 h : anneau + titre + % | anneau + % | **anneau seul** |
| Bouton réglages | 44 × 44 | 44 × 44 | 44 × 44 |
| Règle : hauteur | 36 | 36 | 30 |
| En-tête de piste : largeur `--hw` | 268 | 268 | 96 |
| Colonne fader (téléphone) | — | — | 52 |
| Hauteur de ligne `--rh` | 90 (croît jusqu'à 130) | 90 (croît jusqu'à 130) | 76 (fixe) |
| Largeur utile de l'onde (à 1180 / 820 / 390) | ≈ 892 | ≈ 512 | ≈ 218 |
| Fader de piste | horizontal, `--w: 170px`, h 44 | idem | vertical `.ph`, 52 × `--rh` |
| Dock : hauteur / marges | 112 / `10 20 20` | 104 / `8 20 20` | auto / `8 12 22` |
| Dock : grille | `1fr auto 1fr`, padding `0 22`, écart 20 | `auto 1fr auto`, padding `0 18`, écart 12 | 1 colonne, 2 lignes, padding `12 14`, écart 10 |
| Bouton lecture | 76 | 68 | 64 |
| Boutons retour / boucle | 56 (boucle avec libellé, h 56) | 56 (boucle icône seule, 56 × 56) | 48 (boucle ronde) |
| Fader général (`--w`) | 200 | 150 | 120 |
| Tonalité : boutons | 46 × 46 | 46 × 46 | 38 × 38 |

Règles de hauteur :

- Les lignes de piste ont une **hauteur minimale** `--rh` et grandissent (`flex: 1 1 var(--rh)`,
  `max-height: 130px`) pour remplir l'écran en `dsk` et `tab`. En `pho` elles sont fixes.
- Si les lignes ne tiennent pas (fenêtre trop basse, ou plus de 6 pistes), la **zone des pistes défile
  verticalement** (`overflow-y: auto`), le dock reste fixe. Aucun défilement horizontal, jamais.
- Fenêtre basse, `@media (max-height: 520px)` (téléphone en paysage, 844 × 390 par exemple, qui prend la
  mise en page `tab`) : barre du haut 56, dock 72 (lecture 52, retour/boucle 44), sous-ligne du temps
  masquée, zone des pistes défilante. Pas de maquette dédiée : doit rester utilisable.
- Zones sûres : `viewport-fit=cover` dans la balise viewport ; `padding` du `body` avec
  `env(safe-area-inset-top/right/bottom/left)`. La barre d'état de la maquette téléphone (9:41, batterie)
  est décorative : ne pas la reproduire.

## 4. Composants

### 4.1 Barre du haut

1. **Bouton morceau** (à gauche) : pochette + titre (14/600, ellipse) + sous-ligne `6 pistes · 3:42 · YouTube`
   (le dernier terme est `SOURCE_LABEL`, ex-« Source : … ») + chevron. Ouvre la **bibliothèque** (§ 4.9).
   Sans morceau : pochette grise (trois barres `--faint`), « Aucun morceau » / « Bibliothèque vide ».
2. **Champ de recherche** (§ 4.7), au centre en `dsk`/`tab`, sur sa propre ligne en `pho`.
3. **Jeton d'import** (§ 4.8) puis **bouton réglages** (§ 4.10), à droite. Le jeton n'existe que s'il y a
   un import ; sans import, seul le bouton réglages reste.

**Pochette** : boîte 40 × 40 (r9, `--s2`, padding 6, barres alignées en bas, écart 2) contenant une barre
verticale par piste, dans la couleur de la piste. Hauteurs 30 à 100 % déterministes (graine = id du
morceau). Si les noms de pistes ne sont pas stockés avec le morceau, utiliser 6 barres aux couleurs par
défaut (6 pistes), les 5 couleurs `[chant, guitare, basse, batteries, autre]` (5 pistes) ou les 4 premières
(4 pistes). À vérifier dans le format de bibliothèque, ne pas le modifier.

### 4.2 Règle, boucle et tête de lecture

Calque `.ov` positionné sur les lignes de piste : `left = gouttière + --hw`, `right = gouttière`
(téléphone : `right = gouttière + 52`), `top: 0`, `bottom: 0`, `pointer-events: none` (sauf poignées).

- **Graduations** : étiquettes `m:ss` mono 10.5 px `--faint`, petit trait de 5 px au-dessus. Pas existant
  (`drawRuler` : 10, 15 ou 30 s selon la durée), **élargi** pour garder au moins 56 px entre deux
  étiquettes (pas choisi parmi 10, 15, 30, 60, 120 s). Maquette : 30 s en `dsk`/`tab`, 60 s en `pho`.
- **Tête de lecture** : trait blanc de 2 px, halo `0 0 8px rgba(255,255,255,.5)`, toute la hauteur.
- **Boucle** (visible dès que A et B existent) :
  - barre de titre sur la règle : hauteur 30 (téléphone 26), r9, fond `--acc`, texte `--acc-ink`,
    lettres **A** à gauche et **B** à droite (12/700 ; masquées en `pho`) ;
  - zone sous la règle : fond `rgba(196,242,74,.09)`, bordures gauche et droite 2 px `--acc` ;
  - deux **poignées** : pastille `--acc` 18 × 46, r9, ombre `0 4px 14px rgba(0,0,0,.5)`, barre centrale
    4 × 20 `--acc-ink` à 55 %, centrée verticalement sur la zone des pistes (téléphone 16 × 40) ;
  - boucle **désactivée** (`loop.on = false`) : mêmes éléments à 45 % d'opacité, sans accent plein.
- **Gestes** (règle et lignes de piste) :

| Geste | Effet |
|-------|-------|
| Toucher / cliquer la règle ou une onde | `seek` (comportement actuel) |
| Glisser sur la **règle**, sans modificateur | pose une boucle (`loop.a/b` = bornes, `loop.on = true`), `seek` au début à la fin du geste. Remplace Maj + glisser, **impossible au tactile** |
| Maj + glisser sur une onde ou la règle (souris) | idem, comportement actuel conservé |
| Glisser une poignée | déplace A ou B, écart minimal 0,2 s, bornes 0 et durée |
| Toucher la lettre **A** ou **B** de la barre **[spec]** | place A ou B à la position actuelle (remplace les boutons A et B) |
| Toucher la croix ✕ (22 px, au centre de la barre) **[spec]** | efface la boucle (remplace le bouton ✕) |

Toutes les zones de geste ont `touch-action: none`. Le geste suit le pointeur avec
`setPointerCapture`. Pendant un geste sur poignée, l'audio n'est relancé qu'à la fin (`restartIfPlaying`),
comme aujourd'hui.

### 4.3 Ligne de piste

Une ligne par piste (jusqu'à 9). `<div class="track" data-i>` : fond `--s1`, r14, `overflow: hidden`.
Grille `--hw 1fr` (téléphone : `--hw 1fr 52px`).

**`dsk` et `tab` (fader horizontal)** : en-tête de 268 px, bordure gauche 6 px de la couleur de la piste.

```
┌ ▌ Batteries                    [M] [S] ┐   ligne 1 : nom (15/600, ellipse) | M | S
│ ▌ ◂━━━━━━━●━━━━━ ┆ ┆ ┆   −4.5 dB      │   ligne 2 : fader horizontal (170 px) | valeur dB
└────────────────────────────────────────┘   puis l'onde (1fr)
```

- Ligne 1 : nom (flex 1, ellipse, `title` = nom du fichier) puis M puis S, espacés de 8 px.
- Ligne 2 : fader horizontal (§ 5), puis la valeur `−4.5` (mono 13/600, `--dim`) suivie de `dB` (mono 10 px,
  `--faint`). `−∞` si coupé. Espacement entre lignes 6 px, contenu centré verticalement.
- Retirer la mention « touche N » sous le nom (elle reste dans les raccourcis des réglages).

**`pho` (fader vertical au bord droit)** : colonnes `96px 1fr 52px`.

```
┌▌Chant      ┬──────────────────┬──┐
│ [M][S]     │  onde            │▮ │   gauche : nom 13/600, M/S 36×32, valeur 11 mono
│ −1.5 dB    │                  │▮ │   droite : fader vertical .ph (52 px de large)
└────────────┴──────────────────┴──┘
```

- Gauche : bordure 4 px couleur de piste, padding gauche 10, trois lignes (nom, M/S côte à côte avec 6 px,
  valeur), centrées verticalement.
- Fader vertical **`.ph`** (§ 5.4) dans la dernière colonne.

**Onde** : cellule `1fr`, bordure gauche 1 px `--ln`, fond `rgba(255,255,255,.02)`, canvas en position
absolue (marges haute et basse : voir § 6).

**État « silencieux »** (mute, ou solo ailleurs) : onde à 20 % d'opacité, nom en `--dim`, valeur à 55 %,
capuchon désaturé (`saturate(.15) brightness(.65)`), crête à zéro. Transition de l'opacité de l'onde 0.15 s.

**Boutons M et S** : 42 × 36, r10, fond `--s2`, bordure `--ln`, lettre 13/700 `--dim` (téléphone 36 × 32,
r9). M actif : fond et bordure `--mute`, lettre blanche. S actif : fond et bordure `--solo`, lettre
`#1a1400`. `aria-pressed`. Solo **exclusif** : Alt ou Cmd + clic (existant) ; **[spec]** appui long de
500 ms sur S au tactile.

### 4.4 Dock de transport

Validé tel quel. Trois groupes : **lecture** (gauche), **position et tonalité** (centre), **sortie** (droite).

**`dsk`** : `[retour 56] [lecture 76] [Boucle ⟲ 56 h]` — `1:24` (38 px) avec sous-ligne
`sur 3:42 · boucle 1:05 → 1:38` — bloc **Tonalité** — « Général », badge `LIM`, valeur dB, fader horizontal
200 px avec crête intégrée.

**`tab`** : même ordre sur une ligne ; Boucle réduite à l'icône (56 × 56) ; sous-ligne `sur 3:42` seule ;
fader général 150 px.

**`pho`** : ligne 1 = retour 48, lecture 64, boucle 48 ronde, puis le temps `1:24` aligné à droite (30 px,
sous-ligne `sur 3:42`). Ligne 2 = bloc Tonalité (boutons 38) à gauche, « Général » + fader 120 px à droite.

- **Lecture** : cercle plein `--s2` (retour) et bouton lecture. Icône lecture ▶ / pause ❚❚ (SVG existants).
  Pendant `starting` (préparation de la transposition) : bouton désactivé à 60 %.
- **Boucle** : bascule `loop.on`. Actif : fond `--acc`, texte `--acc-ink`. Sans boucle valide : bouton
  désactivé à 45 %, `title` « Glisse sur la règle pour poser une boucle ».
- **Temps** : `fmt(position)` en grand, sous-ligne `sur {durée}` puis `· boucle a → b` **seulement si la
  boucle est valide et active**.
- **Tonalité** : cadre `--s2` r16 padding 6, boutons −/+ (46 × 46, fond `--s3`, r12, désactivés aux bornes
  `±PITCH_MAX`), au centre la valeur (`+2`, `−3`, `0`) et dessous le libellé `Tonalité` (10 px, majuscules).
  Clic sur la valeur = retour à 0 (existant). Le texte d'état de transposition (`setPitchStatus`) remplace
  temporairement le libellé `Tonalité` ; en erreur il passe en `--mute`.
- **Général** : libellé + badge `LIM` + valeur (`0.0 dB`) au-dessus du fader. Le badge s'allume en `--mute`
  quand le limiteur agit (`meter.limitAt` < 1 s). La crête de sortie (`meter.peak`, avant limiteur) est
  dessinée dans le fader (§ 5.5). Double-clic = 0 dB.
- **Tout réactiver** **[spec]** : bouton fantôme (« Tout réactiver », 12/600, bordure `--ln`, fond
  transparent) dans la **cellule vide à gauche de la règle** (largeur `--hw`), visible seulement si au moins
  un mute ou un solo est actif. `pho` : libellé « Réactiver », 11 px. Même action que `Échap` (`resetMix`).

### 4.5 Fader de console

Voir § 5 (composant partagé par les pistes, le dock et le téléphone).

### 4.6 Premier lancement, vide

Affiché quand la bibliothèque est vide et qu'aucun morceau n'est ouvert (remplace l'ancien `.empty`).

- Les 6 lignes de piste sont dessinées en **fantôme** : opacité 38 %, `pointer-events: none`, noms par
  défaut (Chant, Guitare, Basse, Batteries, Piano, Autre), faders à leurs valeurs initiales, onde = trait
  plat de 1 px à 45 % d'opacité, M/S au repos.
- Dock éteint : opacité 40 %, `pointer-events: none`, temps `0:00` / `sur 0:00`.
- **Carte centrale** : largeur 540 (max `100% − 32`), centrée (50 % / 46 %), fond `--s2`, bordure
  `rgba(255,255,255,.12)`, r22, padding 28, ombre `0 24px 60px rgba(0,0,0,.6)`. Contenu : six barres
  colorées (7 px de large, hauteurs 16/26/38/22/30/18) ; titre `Ajoute ton premier morceau` (Space Grotesk
  24/600) ; texte `Cherche un titre, colle un lien YouTube ou dépose un fichier. Il est séparé en 6 pistes
  dans ton navigateur : chant, guitare, basse, batteries, piano, autre.` ; trois tuiles (86 de haut, r14)
  `Chercher sur YouTube` (accent plein, **action principale**), `Coller un lien`, `Importer un fichier` ;
  note `Tout reste sur cet appareil, dans ta bibliothèque.` (12 px `--faint`).
- `pho` : tuiles empilées (50 de haut, icône + libellé en ligne), carte `100% − 24`, titre 20.
- Les tuiles : « Chercher » met le focus dans le champ ; « Coller un lien » le focus aussi avec le
  placeholder `Colle un lien YouTube` ; « Importer un fichier » ouvre le sélecteur de fichier.
- Le champ du haut est en état **actif** (anneau accent) à l'ouverture.
- Si Chrome/Safari impose un geste utilisateur pour le focus automatique (iOS), ne pas forcer le focus :
  l'anneau accent seul suffit.

### 4.7 Champ de recherche et feuille de résultats

Un champ unique, toujours visible. Il accepte un titre, un lien YouTube, et sert aussi de filtre sur la
bibliothèque. **Un fichier ne passe jamais par le champ.**

- **Repos** : fond `--s2`, bordure `--ln`, icône loupe 20 px, placeholder `Chercher un morceau ou coller un
  lien` (téléphone : `Chercher ou coller un lien`), puis bouton fichier (34 × 34, `--s3`, icône fichier),
  puis bouton `Chercher` (`dsk`/`tab` seulement : h 34, r10, fond `--acc`, 13/700).
- **Actif** (focus, ou feuille ouverte) : bordure `color-mix(in srgb, var(--acc) 70%, transparent)`, anneau
  `0 0 0 3px color-mix(in srgb, var(--acc) 18%, transparent)`, fond `--s1`, curseur de texte `--acc`
  (1.5 × 16 px). Téléphone : une croix ronde (30 px) efface le texte.
- **Ouverture** : focus du champ ouvre la **feuille** (même vide : onglets + dépôt + bibliothèque). La
  feuille couvre la zone sous la barre du haut (`top: 68px`, téléphone `top: 156px`), fond `#0b0d10`,
  `z-index` 30, au-dessus du dock et des pistes (voile `.scrim` derrière).
- **Frappe** : à chaque caractère, filtre **local** immédiat sur les titres de la bibliothèque (carte
  « Dans ta bibliothèque » en tête). La recherche réseau (relais) ne part que sur **Entrée** ou le bouton
  `Chercher`, comme aujourd'hui, pas en direct.
- **Type d'entrée** : si le texte est un lien YouTube (`youtu.be`, `youtube.com/watch`, `/shorts`), le
  bouton devient `Afficher` et appelle la logique actuelle de l'onglet « Lien YouTube » (une carte vidéo).
  Sinon, recherche par titre (onglet « Rechercher »).
- **Fermeture** : `Échap`, clic sur le voile, ou croix ; le champ perd le focus. `Échap` ferme avant de
  faire `resetMix`.
- **Raccourcis** : `/` met le focus dans le champ (hors champ de saisie) ; `Ctrl/Cmd + O` ouvre le sélecteur
  de fichier (`dsk`).

**Feuille `dsk`** (padding 20 24) : rangée de **chips** hauteur 38, r19 : `Tout` (actif : fond `--acc`),
`YouTube`, `Bibliothèque`, `Fichier`, puis à droite `Résultats pour « … »` (13 px `--dim`). Deux colonnes :
`1fr` de cartes (grille 3 colonnes, écart 14) et 300 px de colonne latérale.

- Carte **bibliothèque** (pleine largeur, fond `color-mix(--acc 9%, --s1)`, bordure `--acc` à 35 %) :
  pochette 48, titre, `Déjà dans ta bibliothèque · 4 pistes`, boutons `Supprimer` (fantôme) et `Ouvrir`
  (accent). Détection : même identifiant vidéo si la métadonnée existe, sinon titre normalisé. À vérifier
  dans le format de bibliothèque.
- Carte **YouTube** : vignette 16:9 r12 (`i.ytimg.com`, repli : dégradé), badge durée en bas à droite
  (fond `rgba(0,0,0,.72)`), titre 14/600, chaîne 12 `--dim`, boutons `Aperçu` (fantôme) et `Importer`
  (accent), 44 de haut, r12. `Importer` est désactivé et accompagné de `MSG.tooLong` si la vidéo dépasse
  `MAX_SEC`. `Aperçu` garde le comportement actuel (lecteur `youtube-nocookie`).
- Colonne latérale : zone de dépôt (bordure 1.5 px pointillée `rgba(255,255,255,.2)`, r18, icône fichier,
  `Déposer un fichier audio`, `MP3, M4A, WAV, WebM, FLAC`, bouton `Choisir un fichier`) et une ligne
  `Coller un lien YouTube` (50 de haut, r14). **[spec]** sous la zone de dépôt, lien discret
  `ou un dossier de pistes MP3` (voir § 4.9) sur les plateformes qui acceptent `webkitdirectory`.
- Pas de résultat : note `MSG.noResult`. Chargement : `Recherche…` et trois cartes squelettes.

**Feuille `tab`** : mêmes chips ; cartes en **une colonne**, rangées horizontales (vignette 190 px, titre,
boutons à droite, padding 10) ; carte bibliothèque en tête ; colonne latérale passée sous les cartes en deux
colonnes (dépôt, lien).

**Feuille `pho`** (padding 10 12) : chips `Tout`, `YouTube`, `Bibliothèque` (34 de haut, 12.5 px) ; liste de
cartes `.it` (r14, padding 8, grille `auto 1fr auto`) : vignette 84 × 47 (ou pochette), titre 13/600 sur
deux lignes, sous-ligne 11.5, bouton `Importer` (40 de haut, r11) ou `Ouvrir` (accent) ; en bas deux tuiles
pointillées côte à côte : `Fichier audio` et `Coller un lien`.

### 4.8 Jeton d'import et liste des imports

- **Jeton** : pastille h 32 (`--s2`, bordure `--ln`, r999), anneau 20 px (rayon 8, trait 2.5, piste
  `rgba(255,255,255,.14)`, arc `--acc`, `stroke-linecap: round`, départ à midi), puis titre et `62 %`
  (`em`, `--dim`). `tab` : anneau + `%`. `pho` : anneau seul. Ouvert : bordure `--acc`.
- Plusieurs imports : le jeton montre l'import **en cours** (pas ceux en attente) ; si seuls des échecs
  restent, anneau complet `--mute` avec `!` et libellé `Échec`.
- **Liste** (popover) : `dsk`/`tab` ancrée sous le jeton (`top: 60`, `right: 20`, largeur 380, padding 16,
  fond `--s1`, bordure `rgba(255,255,255,.14)`, r18, ombre `0 24px 60px rgba(0,0,0,.65)`) ; `pho`
  `left: 12`, `right: 12`, `top: 98`. Voile derrière. Fermeture : `Échap`, clic dehors, `Fermer`.
- Titre `IMPORTS` (11/600 majuscules `--dim`). Une carte par import (`--s2`, r14, padding 14) :
  - **en cours** : titre, `62 %` (mono, `--acc`), bouton `Annuler` ; barre de 6 px (`--s3`, remplissage
    `--acc`) ; les **étapes existantes** (`jobSteps(j)` : 4 étapes) avec pastille 16 px : terminée = disque
    `--ok` et ✓, courante = anneau `--acc` et ›, à venir = anneau `--faint` ; détail après l'étape courante
    (`Séparation en 6 pistes · tranche 5/12`) ; note `Tu peux fermer ce panneau et écouter autre chose
    pendant le calcul.`
  - **en attente** : titre + note `En attente : un import à la fois.`
  - **échec** : fond `rgba(255,90,95,.08)`, bordure `rgba(255,90,95,.35)`, titre, bouton `Fermer`, message
    d'erreur en `#ffb0b3` (`MSG.*` existants : mémoire, stockage, appareil, vidéo trop longue…).
- À la fin d'un import : toast `« Titre » est prête` avec action `Ouvrir`, le jeton disparaît. Le morceau
  apparaît dans la bibliothèque.

### 4.9 Bibliothèque (liste des morceaux) **[spec]**

Ouverte par le bouton morceau. Remplace la barre latérale actuelle (`aside`, `renderSongList`).

- `dsk`/`tab` : popover ancré sous le bouton, largeur 360, hauteur max 70 % de la fenêtre, défilement
  interne. `pho` : feuille basse (pleine largeur, hauteur max 85 %, r24 en haut, poignée de tirage 36 × 4).
  Même fond, bordure, ombre et voile que les autres popovers.
- Champ `Filtrer…` en tête (h 36, r10) quand il y a plus de 5 morceaux.
- Sections (11/600 majuscules `--dim`) : `Imports` (mêmes données que `renderJobs`, ligne = titre + barre
  fine + `%` ; un clic ouvre la liste des imports), `Bibliothèque`, `Dossier`.
- Ligne de morceau : pochette 40, titre 13/600, sous-ligne `YouTube · 3:42` (`SOURCE_LABEL` · `fmt(durée)`),
  croix ✕ (44 × 44 de zone tactile). Morceau ouvert : fond `--s2`. Clic = `loadSong('l:' + id)`.
- Suppression : un clic sur ✕ remplace la ligne par `Supprimer « Titre » ?` avec `Supprimer` (fond
  `--mute`) et `Annuler` (comportement `confirmDelete` actuel).
- `Dossier` : morceaux issus d'un dossier de pistes MP3 (`songs`), sous-ligne `n pistes`. Bouton
  `Choisir un dossier de pistes MP3…` en pied de liste, **masqué sur iPad et iPhone** (pas de
  `webkitdirectory`). Remplace le bouton `#pick` de l'ancien en-tête.
- Bibliothèque et dossier vides : texte `Rien ici pour l'instant.` et lien vers la recherche.

### 4.10 Réglages **[spec]**

Bouton de la barre du haut (icône curseurs, 44 × 44). Ouvre un popover du même type que les imports.
Contenu = l'ancien pied de panneau (`renderFooter`) plus les raccourcis :

- `Relais configuré · Oublier ce relais` (confirmation en ligne), ou le champ d'invitation existant
  (`inviteField()`) quand le relais est absent ou en erreur (hors `MSG.relayDown`).
- `Espace utilisé : … · disponible : …` ; ajout ` — presque plein` sous 500 Mo, en `--mute`.
- Crédits Demucs (htdemucs_6s, Meta, MIT, ONNX Runtime Web, kramp/audio-split) et lien de confidentialité
  Turnstile (textes actuels).
- `Raccourcis` (`dsk` seulement) : la liste actuelle de la ligne `.keys`, plus `/` chercher et `⌘/Ctrl O`
  fichier. La ligne `.keys` disparaît de l'écran principal.

### 4.11 Écrans d'état

**Relais indisponible** (recherche impossible) : feuille ouverte avec le texte saisi ; chip `YouTube` grisé
(opacité 50 %) avec une pastille `--mute` de 7 px ; **bandeau** pleine largeur (`rgba(255,90,95,.09)`,
bordure `rgba(255,90,95,.32)`, r18, padding 16) : icône d'alerte dans un disque 46 px, titre
`Recherche indisponible`, texte `Le relais ne répond pas. Tu peux importer un fichier.`, boutons
`Réessayer` (neutre) et `Importer un fichier` (accent), 44 de haut, r12. Dessous : carte bibliothèque
encore utilisable, zone de dépôt active, ligne `Coller un lien YouTube` à 50 %. `pho` : bandeau en une
colonne, boutons à parts égales (42 de haut). Texte du bandeau issu de `MSG.relayDown`.
Autres causes : lien d'invitation absent (`relay.state === 'none'`, texte existant, avec la variante
téléphone/tablette), recherche sans résultat (`MSG.noResult`) : même bandeau, mêmes boutons selon le cas.

**Fichier glissé** (`dsk`) : tout `dragenter` d'un fichier sur la fenêtre affiche un écran de dépôt
(`inset: 0`, `z-index: 60`, fond `rgba(9,10,12,.88)`, padding 18) avec un cadre pointillé 2 px `--acc`
(r26, fond `color-mix(--acc 7%, transparent)`), disque `--acc` de 72 px avec icône fichier, titre
`Dépose ton fichier audio` (26/600), texte `MP3, M4A, WAV, WebM, FLAC` puis `Il sera séparé en 6 pistes dans
ton navigateur.` Le dépôt appelle le même import qu'aujourd'hui. `dragleave` / `Échap` le ferme. Sur
tablette et téléphone, pas de glisser-déposer : le **bouton fichier du champ** est la voie principale.

**Import de fichier, trois entrées** (aucune ne demande de taper) : bouton fichier dans le champ,
dépôt sur la fenêtre, `Ctrl/Cmd + O`. Plus les tuiles du premier lancement et de la feuille.

### 4.12 Toasts et bannière de mise à jour **[spec]**

Style unique : fond `--s2`, bordure `--ln`, r14, ombre `0 12px 30px rgba(0,0,0,.5)`, padding `10 14`, texte
13 px, bouton d'action accent (h 34, r10). Position : centré en bas, 16 px **au-dessus du dock**.
La bannière « Nouvelle version disponible » + `Recharger` (`#updateBanner`, `[hidden]` respecté) reprend
ce style. Durée du toast inchangée.

## 5. Fader de console

Un composant, deux orientations, utilisé par : fader de piste (`dsk`/`tab`), fader général (tous), fader
de piste vertical `.ph` (`pho`). Le fader **vertical pleine taille** de l'étude (en-tête de 252 px) est
**écarté** : ne pas le construire.

### 5.1 Valeurs

- Plage `DB_OFF = −41` à `+6` dB, pas de 0,5 dB. `−41` = coupé (affichage `−∞`, gain 0). Valeur initiale
  = `tr.db` / `masterDb`. Gain = `dbToGain(db)` (inchangé).
- **Loi de console** : position `p` (0 à 1, 0 = gauche ou bas) par interpolation linéaire entre ces ancres :

| dB | −41 | −30 | −20 | −10 | 0 | +6 |
|----|-----|-----|-----|-----|---|----|
| p | 0 | 0,17 | 0,36 | 0,58 | 0,80 | 1 |

```js
const ANC = [[-41,0],[-30,.17],[-20,.36],[-10,.58],[0,.8],[6,1]];
const pos = db => { if (db <= -41) return 0; if (db >= 6) return 1;
  for (let i = 1; i < ANC.length; i++) if (db <= ANC[i][0]) { const a = ANC[i-1], b = ANC[i];
    return a[1] + (db - a[0]) / (b[0] - a[0]) * (b[1] - a[1]); } return 1; };
const unpos = p => { p = Math.max(0, Math.min(1, p));
  for (let i = 1; i < ANC.length; i++) if (p <= ANC[i][1]) { const a = ANC[i-1], b = ANC[i];
    return a[0] + (p - a[1]) / (b[1] - a[1]) * (b[0] - a[0]); } return 6; };
```

- **Aimantation** après `unpos` : `db = round(db × 2) / 2` ; si `|db| < 0,8` alors `db = 0` ; si `db ≤ −40`
  alors `db = −41`.

### 5.2 Géométrie horizontale (`.hf`)

Zone `--w` (défaut 200) × 44. Rail : `left/right: 13px`, `top: 19px`, hauteur 5, r3, fond `--rail`, ombre
interne `0 1px 3px rgba(0,0,0,.9)` et `0 1px 0 rgba(255,255,255,.09)`. Remplissage : même géométrie, couleur
`--c` (couleur de piste ; général : `--acc`), opacité .85, largeur `p × (100% − 26px)`.
Graduations (`top: 31px`) à `left: calc(13px + t × (100% − 26px))` pour `t = pos(db)` : mineures 1 × 4 px
`--faint` (−5, −15, −25), majeures 1 × 7 px `--tick` (+6, −10, −20, −30, −41), **0 dB** : 2 × 9 px `--tx`.
Crête (`top: 8px`, hauteur 5, mêmes marges, r2) : fond `--rail`, remplissage `--c`, largeur
`pos(crête dB) × 100 %`, segmentée par un masque `repeating-linear-gradient(to right, transparent 0 2px,
var(--rail) 2px 3px)`. Capuchon : 24 × 36, `top: 3px`, `left: calc(13px + p × (100% − 26px) − 12px)`, r5,
bordure `rgba(0,0,0,.6)`, fond = trait central 2 px de `--c` (hauteur `100% − 10px`) sur dégradé
`linear-gradient(90deg, cap-1, cap-2 47%, cap-3 53%, cap-4)`, reflet `inset 0 1px 0 rgba(255,255,255,.28)`,
ombre `0 4px 8px rgba(0,0,0,.55)`, deux zones striées (3 px de chaque bord, `top/bottom: 6px`, largeur 5,
`repeating-linear-gradient(90deg, rgba(0,0,0,.5) 0 1px, rgba(255,255,255,.12) 1px 2px)`).

Le CSS complet (dont la variante `.sm` de 38 de haut, **non utilisée** dans la version retenue) est dans le
document, blocs `.hf`.

### 5.3 Interaction

- `pointerdown` sur la zone (toute la zone, 44 de haut) : `setPointerCapture`, classe `.drag`, focus sans
  défilement. Sur le **capuchon** : décalage conservé (le capuchon ne saute pas). Sur le **rail** : il saute
  sous le pointeur.
- `pointermove` : `p = (x − gauche) / L` avec `L = largeur − 26` et `x` corrigé du facteur d'échelle ;
  `db = snap(unpos(p + décalage))`. Écriture directe de `--p` sur la zone seulement : **ne pas refaire le rendu
  de la ligne**. `applyMix()` (ou `setMaster`) pour le gain, throttlé par `requestAnimationFrame`.
- `pointerup` / `pointercancel` : retire `.drag`. `dblclick` / double-tap : 0 dB.
- Clavier : `role="slider"`, `tabindex="0"`, `aria-valuemin="-41"`, `aria-valuemax="6"`, `aria-valuenow`,
  `aria-valuetext="−3.0 dB"`, `aria-label="Volume Guitare"` ; flèches ±0,5, `Maj` ±3, `Début` = −41, `Fin` = +6.
- **Réglage fin** **[spec, à prototyper]** : pendant un geste, l'écart perpendiculaire du pointeur par
  rapport au rail divise la vitesse (×1 à ≤ 24 px, ×0,5 de 24 à 80 px, ×0,25 au-delà).
- `touch-action: none`, `user-select: none`, `-webkit-user-select: none`.
- État **saisi** (`.drag`) : capuchon `filter: brightness(1.28)`, halo `0 0 0 3px color-mix(--c 45%, transparent)`.
  Focus clavier : contour 2 px blanc, décalage 2.
- Sur appareils à souris seulement, `:hover` sur le capuchon : `brightness(1.12)` (`@media (hover: hover)`).

### 5.4 Version verticale `.ph` (téléphone)

Zone 52 × `--rh` (76). Rail vertical : `left: 21px`, largeur 6, `top/bottom: 10px`. Remplissage depuis le bas,
hauteur `p × (100% − 20px)`. Graduations à `left: 43px` (mineures 4 × 1, majeures 5 × 1, 0 dB : `left: 42px`,
7 × 2) ; pas d'étiquettes chiffrées. Crête : `left: 48px`, largeur 4, `top/bottom: 10px`, segments
(`repeating-linear-gradient(to bottom, transparent 0 2px, var(--rail) 2px 3px)`). Capuchon 40 × 26, `left: 3px`,
`top: calc(10px + (1 − p) × (100% − 20px) − 13px)`, fond avec dégradé `180deg`, striures horizontales
(`top: 4px` et `bottom: 4px`, hauteur 5). **Bulle** de valeur pendant `.drag` : à gauche du capuchon
(`right: calc(100% + 4px)`), fond blanc, texte `#0e0f12`, mono 13/600, `−39.5 dB`.
Les mêmes ancres `pos()` : le capuchon d'un fader vertical à −6 dB est à la même fraction que l'horizontal.

### 5.5 Crête (post-fader)

- **Fader de piste** : crête **après le gain de piste** et avant le bus général. Une mesure par piste, via un
  `AnalyserNode` branché après `t.gain` (6 nœuds de plus) ; valeur = crête sur la dernière fenêtre
  (`getFloatTimeDomainData` ou `getByteTimeDomainData`), échelle `pos(dB)` avec chute lente (≈ 20 dB/s). Une
  seule boucle `requestAnimationFrame` pour toutes les crêtes, arrêtée à l'arrêt de lecture.
- **Fader général** : remplace l'échelle linéaire actuelle (−48 … +6) de `#mfill` par `pos(meter.peak)`,
  même source (`meter.peak`, avant limiteur).
- **Étape optionnelle** (`06-handoff-redesign.md`, étape +) : sans les `AnalyserNode`, **masquer** la crête des pistes
  (`display: none`) ; le fader et tout le reste fonctionnent à l'identique. Ne jamais afficher de crête
  simulée (la maquette anime des valeurs factices : ne pas porter ce code).
- `prefers-reduced-motion` : pas de chute animée, valeur instantanée.

## 6. Formes d'onde

**Inchangées** par rapport à `drawWaves`, `toPcm16`, `waveBins` : une colonne par pixel CSS (`fillRect` de
`1 × h`, minimum 1 px), symétriques autour de l'axe, normalisation `0.9 / max(crête, 0.05)`, couleur de
piste, largeur relative si la piste est plus courte que le morceau (`scale`). Les barres arrondies de la
première étude sont **abandonnées**.

Changements limités à l'emballage :

- Pas de dégradé de lecture : **pleine couleur partout** (la partie non jouée n'est pas atténuée).
- Canvas en position absolue dans la cellule (`left: 0; width: 100%`), `top/bottom: var(--pad)` avec
  `--pad: 6px` (`dsk`/`tab`) et `5px` (`pho`). Rendu à `devicePixelRatio` (existant).
- Rendu à refaire au changement de taille de fenêtre (`resize` / `ResizeObserver`, debounce 60 ms), car la
  largeur utile change entre `dsk`, `tab` et `pho`. Invalider le cache `tr.wave` quand `bins` change
  (comportement actuel).
- Ligne fantôme (premier lancement) : trait plat 1 px, 45 % d'opacité, couleur de la piste.

## 7. Comportements et fonctions existantes

| Fonction (`index.html`) | Devenir |
|-------------------------|---------|
| `renderSong` | Réécrite : nouvelle barre du haut, lignes de piste, dock, calque de boucle. Garde les mêmes `id` utiles aux tests si possible. |
| `renderSongList`, `#songs`, `aside` | Remplacés par la bibliothèque (§ 4.9). |
| `openPanel`, `closePanel`, `renderPanel`, onglets Rechercher / Lien / Fichier | Remplacés par le champ + la feuille (§ 4.7). La **logique** (recherche, aperçu, import, états du relais) est conservée ; seul le rendu et le déclenchement changent. |
| `renderJobs`, `jobSteps`, `cancelJob` | Rendu dans le popover d'imports (§ 4.8). |
| `renderFooter` | Contenu déplacé dans les réglages (§ 4.10). |
| `toast`, `#updateBanner` | Restylés (§ 4.12). |
| `applyMix`, `toggleSolo`, `resetMix` | Inchangés ; ajouter la mise à jour de `--p`, des valeurs et des classes `silent`. |
| `setMarker`, `toggleLoop`, `updateLoopUI`, `attachLaneMouse` | Étendus : poignées, glisser sur la règle, A/B tactiles (§ 4.2). |
| `tick` | Garde la tête de lecture et le temps ; la crête générale passe à `pos()`. |
| Gestionnaire `keydown` | Inchangé, plus `/` et `Ctrl/Cmd + O`, et priorité à la fermeture des calques sur `Échap`. |

Clavier conservé : `Espace` lecture/pause, `Entrée` début, `1`–`9` mute, `Maj` + `1`–`9` solo, `Échap` tout
réactiver, `←`/`→` ± 5 s, `L` boucle, `↑`/`↓` tonalité, clic sur une piste pour se déplacer, `Maj` + glisser
pour une boucle.

Nombre de pistes : 1 à 9 (`ORDER`). Moins de 6 : les lignes grandissent (max 130) et laissent du vide en bas.
Plus de 6 : zone des pistes défilante.

Mouvement : transitions de 0,15 s sur opacité et couleur des boutons ; aucune animation décorative.
`@media (prefers-reduced-motion: reduce)` : transitions coupées.

## 8. Accessibilité

- Tous les boutons à icône ont un `aria-label` (`Lecture`, `Retour au début`, `Boucle`, `Moins`, `Plus`,
  `Réglages`, `Importer un fichier audio`, `Couper Guitare`, `Solo Guitare`…).
- M et S : `aria-pressed`. Faders : `role="slider"` (§ 5.3). Popovers et feuille : focus piégé, `Échap` ferme,
  le focus revient au déclencheur. Liste d'étapes d'import : `<ol>`. Résultats : `role="list"`.
- Contraste : texte `--tx` sur `--s1` ≥ 12:1 ; `--dim` sur `--s1` ≥ 5:1 ; `--faint` réservé aux
  graduations et textes non essentiels. Texte `--acc-ink` sur `--acc` ≥ 11:1. Ne pas transmettre
  une information par la couleur seule (le silence d'une piste passe aussi par l'opacité, l'erreur par une icône).
- Cibles tactiles : § 2.3. Pas de survol requis pour une fonction.

## 9. Cas non dessinés (récapitulatif)

Tout ce qui est marqué **[spec]** plus : plus de 6 pistes, fenêtre basse, paysage téléphone, bibliothèque
(§ 4.9), réglages (§ 4.10), toasts (§ 4.12), A/B et ✕ de boucle au toucher, appui long solo exclusif, bouton
« Tout réactiver », réglage fin des faders. Ces rendus sont à montrer à Yannick en captures (trois tailles)
avant fusion de l'étape concernée.

Hors périmètre : thème clair, comptes et projets partagés (phase 2), export MIDI, police hébergée, paysage
téléphone dédié, mixeur en tiroir (direction C), fader vertical pleine taille.

## 10. Critères d'acceptation

### 10.1 Fidélité au document

Pour chaque combinaison **taille × vue**, comparer l'app au document ouvert à la même taille.
Tolérance : 2 px sur les dimensions du § 3.2, couleurs identiques aux jetons, mêmes textes.

| Taille de contrôle | Appareil visé |
|--------------------|---------------|
| 1180 × 820 | iPad Air paysage, ordinateur |
| 1024 × 768 | iPad paysage minimal (bascule `dsk`) |
| 820 × 1180 | iPad portrait |
| 744 × 1133 | iPad mini portrait |
| 390 × 844 | iPhone |
| 360 × 740 | petit Android |
| 375 × 667 | iPhone SE (pistes défilantes) |
| 844 × 390 | téléphone en paysage (utilisable, pas de maquette) |

Vues : lecture, recherche ouverte, premier lancement, import en cours (avec un import en échec),
relais indisponible, fichier glissé (`dsk`).

### 10.2 Fonctions

| # | Critère |
|---|---------|
| N1 | Aucune régression sur F1–F15 de `03-tests.md` (lecture synchro, mute/solo/volume, boucle, transposition, limiteur, recherche, aperçu, imports, bibliothèque, bannière, sans clé, transfert). |
| N2 | Le fader de chaque piste est visible et réglable en permanence, à 390, 820 et 1180 px, sans ouvrir de menu. |
| N3 | Un fader suit le doigt et la souris, aimante à 0 dB, double-tap = 0 dB, `−∞` coupe, clavier OK, pas de défilement de la page pendant le geste. |
| N4 | Le champ de recherche est visible sans geste préalable sur tout écran et ouvre la feuille au focus. Un titre trouve en un `Entrée`, un lien YouTube s'affiche, un fichier s'importe **sans taper dans le champ**. |
| N5 | Boucle posée au doigt sur la règle, déplacée par poignées, effacée, activée/désactivée. Plus aucune fonction ne dépend de la touche Maj. |
| N6 | Un import en cours est suivi dans le jeton et son popover ; fermer le popover ne l'interrompt pas ; la fin affiche un toast avec `Ouvrir`. |
| N7 | Relais coupé : bandeau, fichier et bibliothèque restent utilisables. |
| N8 | Premier lancement affiché quand bibliothèque et morceau sont vides ; disparaît dès qu'un morceau s'ouvre. |
| N9 | Aucun défilement horizontal de la page, de 320 à 1920 px de large. Rien ne déborde du cadre à 360 px. |
| N10 | Zones sûres respectées sur iPhone (encoche, barre d'accueil) : rien de cliquable sous la barre d'accueil. |
| N11 | Console propre ; aucun rapport CSP (pas de ressource externe) ; poids de `index.html` < 140 Ko. |
| N12 | Performance : glisser un fader à 60 i/s sur iPad sans coupure du son ; pas de refaire complet des lignes pendant le geste. |

Plateformes et simulateurs : mêmes que `03-tests.md` (CH, SF, FF, IP, IH, AN).
