# Lecteur multipistes — documentation

Lecteur de pistes séparées (stems) pour répéter : une chanson = un dossier de pistes MP3 (Chant, Guitare, Basse, Batteries, Piano, Autre), lues en synchro avec mute / solo / volume, boucle A-B et transposition.

État au 9 octobre 2026. Un seul fichier, sans build : `index.html` (HTML + CSS + JS inline, ~35 Ko).

---

## 1. Arborescence

```
weekend musical oct 2026 (pistes séparées)/
├── index.html                        ← le lecteur
├── DOC.md                            ← ce document
├── madame reve - yeti orange/        ← ancien dossier des AIFF source (vide au 9 oct.)
└── mp3/
    ├── Daniela/                      Daniela  (Basse|Batteries|Chant|Guitare).mp3
    ├── Red Hot Chili Peppers - Breaking The Girl/   (Autre|Basse|Batteries|Chant|Guitare)
    ├── anouk - nobodys wife/         (Basse|Batteries|Chant|Guitare)
    ├── madame rêve/                  (Autre|Basse|Batteries|Chant|Guitare|Piano)
    └── madame reve - yeti orange/    (Autre|Basse|Batteries|Chant|Guitare|Piano)
```

- Convention de nommage : `<titre> (<Instrument>).mp3`. Le lecteur prend le texte entre les **dernières parenthèses** comme nom de piste ; sinon le nom du fichier.
- Le nom de la chanson = nom du **dossier parent** du fichier.
- Le dossier AIFF d'origine (`aiff/`) n'existe plus dans le dossier (retiré par l'utilisateur).

### Conversion AIFF → MP3 (ce qui a été fait)

MP3 CBR 320 kbps, ffmpeg + libmp3lame, en parallèle :

```bash
src="madame reve - yeti orange"; out="mp3/$src"; mkdir -p "$out"
find "$src" -iname '*.aif*' -print0 | xargs -0 -P 4 -I{} sh -c \
  'f="$1"; ffmpeg -nostdin -y -loglevel error -i "$f" -map 0:a -c:a libmp3lame -b:a 320k "$2/$(basename "${f%.*}").mp3"' _ {} "$out"
```

Vérification : durée MP3 = durée AIFF + ~0,03 s (padding de l'encodeur MP3, normal).

Attention : les noms contiennent des accents en **NFD** (macOS). `cd "dossier (pistes séparées)"` tapé à la main peut échouer ; utiliser un glob (`cd weekend*`).

---

## 2. Utilisation

1. Ouvrir https://tipyaf.github.io/mini-webdaw/ , ou `index.html` en local dans Chrome / Safari / Firefox (`file://`, pas de serveur).
2. **Choisir le dossier mp3…** → sélectionner `mp3/` (ou le dossier parent ; seuls les fichiers audio sont gardés).
3. Cliquer une chanson dans la liste.

Un navigateur ne peut pas lister un dossier local tout seul : la sélection est à refaire à chaque ouverture (`<input type="file" webkitdirectory>`).

| Commande | Action |
|---|---|
| Espace | lecture / pause |
| Entrée | retour au début (ou au début de boucle) |
| ← / → | −5 s / +5 s |
| 1 – 9 | mute de la piste n |
| Maj + 1 – 9 | solo de la piste n |
| Alt/Cmd + clic sur S | solo exclusif |
| Échap | tout réactiver (mute/solo) |
| L | boucle on/off |
| ↑ / ↓ (ou pavé +/−) | tonalité ± 1 demi-ton |
| Clic sur une forme d'onde / la règle | se déplacer |
| Maj + glisser | définir une boucle |
| Double-clic sur un fader | 0 dB |

---

## 3. Fonctionnalités

- Liste des chansons (tri alphabétique `fr`), pistes triées : chant, voix, guitare, basse, batterie(s), piano, clavier, autre, puis le reste.
- Par piste : couleur, forme d'onde (canvas, pics calculés depuis l'AudioBuffer), **M**, **S** (cumulable), fader en dB.
- Transport : lecture/pause, retour début, temps, tête de lecture, règle.
- Boucle A-B (boutons A / B / Boucle / ✕, ou Maj+glisser).
- **Tonalité** −12 … +12 demi-tons, tempo inchangé, mémorisée par chanson (en mémoire, pas persistée).
- **Faders en dB** : −∞ (position −41) … +6 dB, pas 0,5 dB, valeur affichée. Volume général idem.
- **Indicateur de crête** (avant limiteur) + voyant **LIM** allumé 1 s quand le limiteur agit.

---

## 4. Architecture audio (Web Audio API)

```
AudioBufferSourceNode ─┐                       (lecture directe, tonalité = 0)
                       ├─► track.gain ─► bus ─► master ─► limiter ─► destination
Signalsmith Stretch ───┘     (mute/solo/   (fondus   (volume    (AudioWorklet,
(tonalité ≠ 0)                fader dB)    transport) général)    plafond −1 dBFS)
```

- `AudioContext({ latencyHint: 'playback' })` : tampon plus grand → moins de décrochages sur tablette.
- Chaque chanson est **entièrement décodée en mémoire** (`decodeAudioData`) au clic. Lourd en RAM : ~6 pistes × 5 min stéréo float32 ≈ 600 Mo. Les buffers de la chanson précédente sont libérés.
- Synchro : toutes les sources démarrent sur la même heure `ctx.currentTime + 0.05` → calage à l'échantillon près.
- Position : horloge maison `offset + (ctx.currentTime − startAt)`, avec repli dans la boucle.

### 4.1 Mute / solo / volume

`audible = !mute && (!anySolo || solo)` → `gain.setTargetAtTime(audible ? dbToGain(db) : 0, now, 0.015)` (lissage ~15 ms, pas de clic).
`dbToGain(db) = db <= -41 ? 0 : 10^(db/20)`.

### 4.2 Fondus de transport (anti-clics)

- `FADE = 12 ms`. `stopAll()` : rampe du `bus` vers 0, puis `source.stop(t + FADE)` — on ne coupe jamais en plein signal.
- `play()` : `fadeIn(when)` rampe 0 → 1 sur 12 ms.
- Concerne lecture, pause, saut, changement de chanson, bascule direct ↔ transposé.

### 4.3 Boucle A-B

- Mode direct : **pas** de `source.loop` natif (saut brutal = clic à chaque tour). À la place, passages successifs programmés 1 s à l'avance (`scheduleLoop`, `setInterval` 100 ms) ; chaque passage a son propre GainNode avec fondu enchaîné de 12 ms à la jonction.
- Mode transposé : boucle native de Signalsmith (`loopStart` / `loopEnd`) — **non traitée pour les clics**, pas testée spécifiquement.
- Modifier la boucle pendant la lecture relance la lecture à la position courante.

### 4.4 Limiteur

- AudioWorklet maison (`LIMITER_CODE`, chargé en `data:` URL) : limiteur crête à anticipation 5 ms, attaque ~1,5 ms, relâchement ~120 ms, plafond −1 dBFS, plus un écrêtage de sécurité au plafond.
- Le volume général est **avant** le limiteur : on peut pousser sans écrêter.
- Repli si AudioWorklet indisponible : `DynamicsCompressorNode` (seuil −1 dB, ratio 20, knee 0).
- Envoie toutes les 50 ms `[crête, réduction de gain]` au thread principal pour l'indicateur.

### 4.5 Transposition (Signalsmith Stretch)

- Librairie : `signalsmith-stretch@1.3.2` (MIT, WASM + AudioWorklet), chargée par CDN :
  `https://cdn.jsdelivr.net/npm/signalsmith-stretch@1.3.2/SignalsmithStretch.js` (balise `<script async id="stretchLib">`). **Connexion internet requise** pour transposer ; la lecture normale fonctionne hors ligne.
- Tonalité 0 → lecture directe (son intact). Tonalité ≠ 0 → un nœud Stretch par piste, créé à la demande (`prepareStretch`, état « préparation… »), canaux copiés et transférés au worklet via `addBuffers`.
- Tous les nœuds sont programmés avec le même `outputTime` + `input` → synchro conservée. Changement de tonalité en cours de lecture : `schedule({ semitones })` sans coupure. Passage 0 ↔ ≠0 : arrêt + relance à la même position.
- Sur écran tactile (`pointer: coarse`) : `configure({ preset: 'cheaper' })` pour limiter la charge CPU.
- **Piège `file://`** : la librairie crée son worklet via une URL `Blob`, refusée par Chrome en `file://` (« Unable to load a worklet's module »). Contournement : on télécharge le script, on le convertit en `data:text/javascript;base64,…` et on le passe via `SignalsmithStretch.moduleUrl` avant le premier nœud. Repli : l'URL CDN directe.
- Piège API : dans `schedule()`, l'heure de sortie se passe dans `outputTime` (la doc parle de `output`) ; le code passe les deux.

---

## 5. Tests réalisés (Chromium headless, Playwright)

| Test | Résultat |
|---|---|
| Transposition +12 sur un sinus 440 Hz (rendu hors ligne) | 880,6 Hz ✅ |
| 6 pistes transposées, coût CPU (rendu hors ligne, conteneur cloud) | ~4× plus rapide que le temps réel ✅ |
| Synchro des 6 nœuds Stretch après +1, +3, saut | `inputTime` identiques au ms ✅ |
| Limiteur sur les vraies pistes de Daniela, faders à 0 dB | brut +0,41 dBFS (764 éch. > 0 dB) → sortie −1,00 dBFS, 0 éch. > 0 dB ✅ |
| Idem avec +6 dB sur tout | brut +6,41 dBFS (533 658 éch.) → sortie −1,00 dBFS, 0 ✅ |
| Transparence du limiteur sous le seuil (sinus −6 dB) | erreur max 0 (simple retard de 5 ms) ✅ |
| Faders dB : +6 / 0 / −6 / −20 / −∞ | gains 1,995 / 1 / 0,501 / 0,1 / 0 ✅ |
| Détection de clics (sinus 440 Hz enregistré en sortie pendant lecture, pause, saut, mute, fader, 8 tours de boucle) | ancienne version : 17 éch. en clic (saut max 0,64) ; nouvelle : 0 (saut max 0,027 < 0,031 admis) ✅ |
| Import des vraies pistes de Daniela | 4 pistes, aucune erreur ✅ |

Méthode de détection de clics : capter la sortie du limiteur (ScriptProcessor), compter les échantillons où `|x[n] − x[n−1]|` dépasse la pente max d'un sinus propre (`2π·440/sr·crête`, +15 %). Le test a été validé en le faisant tourner sur l'ancienne version, où il détecte bien les clics.

En conteneur, le CDN est inaccessible : intercepter `cdn.jsdelivr.net` avec `page.route` et servir le paquet npm local (`npm pack signalsmith-stretch`) avec l'en-tête `access-control-allow-origin: *`. Le chargement du worklet lui-même n'est pas intercepté par `page.route` → d'où aussi l'intérêt du `data:` URL.

### Niveaux mesurés (ffmpeg astats, somme via `amix=normalize=0`)

| Chanson | Piste la plus forte | Somme des pistes |
|---|---|---|
| Daniela | Batteries +0,4 dBFS, Chant +0,1 | **+0,4 dBFS (écrête)** |
| Madame rêve | Chant 0,0 dBFS | −0,4 dBFS |
| Madame rêve – Yeti orange | Batteries −1,3 dBFS | −0,5 dBFS |
| Breaking The Girl | Batteries −5,5 dBFS | −3,6 dBFS |
| Anouk | Batteries −11,6 dBFS | −9,9 dBFS |

---

## 6. Problèmes ouverts

1. **Clics sur tablette — cause non confirmée.** Corrigés : écrêtage (limiteur), coupures sans fondu, boucle native. Non reproduit : décrochages CPU sur tablette (surtout en transposition, 6 nœuds Stretch). Diagnostic sur l'appareil : si **LIM** s'allume au moment des clics → c'était l'écrêtage ; si LIM reste éteint → CPU. Infos à obtenir : appareil, navigateur, chanson, en transposition ou non, en continu ou à l'interaction.
2. **« Impossible de décoder ces fichiers : lastTime is not defined »** signalé à l'import. Non reproduit : le fichier présent déclarait bien la variable, et « is not defined » (V8/SpiderMonkey) indique un script **sans** la déclaration → probablement une autre copie / un onglet en cache. Par précaution, `lastTime` est maintenant déclaré avec l'état global (ligne ~134). À surveiller.
3. Boucle en mode transposé : jonction gérée par Signalsmith, pas de fondu maison, non testée pour les clics.
4. Mémoire : décodage complet en float32 ; risque sur tablette avec les chansons à 6 pistes.
5. Interaction tactile : Maj+glisser (boucle) impossible au doigt ; les boutons A/B restent utilisables. Clic sur les formes d'onde via les événements souris émulés.
6. Sous 760 px de large, les faders de piste sont masqués (CSS).
7. Transposition dépendante du CDN jsDelivr (pas de mode hors ligne).

---

## 7. Nouveau morceau : import, séparation, bibliothèque (oct. 2026)

Bouton **Nouveau morceau** : un morceau devient 6 pistes (Chant, Guitare, Basse, Batteries, Piano, Autre), séparées **dans le navigateur**, puis rangées dans une bibliothèque locale.

- **Sources** : recherche YouTube et lien YouTube (via un relais privé), ou fichier audio (MP3, M4A, WAV, WebM, FLAC).
- **Relais** : son adresse n'est pas dans ce dépôt. Elle arrive par un lien d'invitation `…/mini-webdaw/#relais=<adresse>&cle=<clé>` (gardé en favori ; la partie après `#` n'est jamais envoyée à GitHub), mémorisée dans `localStorage`. Accès : clé du lien → vérification Cloudflare Turnstile invisible → session d'1 h. Sans relais, seul l'onglet Fichier est proposé.
- **Séparation** : Demucs htdemucs_6s (Meta, MIT) en ONNX (`kramp/htdemucs-6s-webgpu-onnx`, 285 Mo, mis en cache après le premier téléchargement), ONNX Runtime Web 1.27 sur **WebGPU**, dans un worker. Tranches de 7,8 s avec 25 % de recouvrement (méthode de l'espace Hugging Face kramp/audio-split, MIT). Seulement sur ordinateur.
- **Séparation sur le serveur** (téléphones, tablettes, ordinateurs sans WebGPU, ou carte graphique qui lâche en cours de route) : le relais sépare lui-même (Demucs sur processeur, ~1 min par minute de musique, un morceau à la fois) et renvoie 6 pistes AAC. Un fichier importé depuis un téléphone est envoyé au relais. `?serveur` dans l'adresse force ce mode depuis un ordinateur. Constat du 22 oct. 2026 : dans le navigateur, Android (Adreno, WebGPU) perd la carte graphique (« Device is lost ») et l'iPad recharge la page faute de mémoire.
- **Bibliothèque** : IndexedDB (`mini-webdaw` : `songs` pour les métadonnées, `stems` pour les pistes). Pistes en **Opus 160 kb/s** (WebCodecs, conteneur Ogg écrit à la main), ou WAV 16 bits si le navigateur ne sait pas encoder puis relire l'Opus. Niveau RMS de chaque piste gardé (`rmsDb`).
- **Déroulé** : un import à la fois (file d'attente), progression par étape (audio, modèle, tranche N/M + temps restant, rangement), Annuler, écran maintenu allumé (Wake Lock). Ouverture automatique à la fin, sauf si un autre morceau joue (notification).

Mesures (M3 Pro, Chrome, 21-22 oct. 2026) : morceau de 2 min 42 importé en ~1 min 10 ; 6 pistes Opus = 18,7 Mo ; réouverture après rechargement en 0,45 s.

Pas encore fait : renommer, export ZIP, capture d'onglet, pistes presque vides repliées, vue compacte téléphone.

## 8. Repères dans le code (`index.html`)

| Zone | Fonctions / constantes |
|---|---|
| Constantes | `FADE`, `CEIL_DB`, `DB_OFF`, `PITCH_MAX`, `TOUCH`, `ORDER`, `COLORS` |
| Chaîne audio | `audioCtx`, `initLimiter`, `LIMITER_CODE`, `fadeIn`, `fadeOut` |
| Chargement | `$('#dir').onchange`, `loadSong`, `trackLabel`, `rank` |
| Rendu | `renderSong`, `renderSongList`, `drawWaves`, `computePeaks`, `drawRuler`, `tick` |
| Relais | `parseInvite`, `setRelay`, `relayCall`, `ensureSession`, `turnstileToken`, `checkRelay` |
| Séparation | `#sepWorker` (worker), `separate`, `separateHere`, `separateOnServer`, `browserCanSeparate`, `decode44k`, `webgpuOk` |
| Encodage | `pickEncoder`, `encodeStem`, `encodeOpus48`, `oggOpus`, `oggPage`, `toWav` |
| Bibliothèque | `library`, `idb`, `libraryFiles`, `deleteLibrarySong` |
| Imports | `enqueue`, `runJobs`, `runJob`, `downloadAudio`, `cancelJob` |
| Panneau | `openPanel`, `renderPanel`, `runSearch`, `runInfo`, `renderResults`, `renderJobs`, `renderFooter` |
| Mixage | `applyMix`, `toggleSolo`, `resetMix`, `dbToGain`, `fmtDb` |
| Transport | `play`, `playStretch`, `startSource`, `scheduleLoop`, `stopAll`, `pause`, `seek`, `position` |
| Boucle | `setMarker`, `toggleLoop`, `loopValid`, `updateLoopUI` |
| Transposition | `prepareStretch`, `releaseStretch`, `setSemis`, `updatePitchUI` |
| Entrées | `attachLaneMouse`, écouteur `keydown` |
