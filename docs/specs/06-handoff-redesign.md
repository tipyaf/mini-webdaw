# 06 — Passation : refonte du front « Scène v2 »

Consigné le 11 nov. 2026. À lire avec `05-redesign-scene-v2.md` (la spec) et
`../design/multipiste-scene-v2.html` (le document de design validé, à ouvrir dans un navigateur).
Dépôt public : aucun secret dans ce dossier.

## 1. Où on en est

- **Étude de design terminée et validée par Yannick. Aucun code de l'app n'a été touché.** `index.html` est
  identique à `main`.
- Le développement **ne démarre pas** tant que Yannick n'a pas donné un go explicite (« lance l'étape 1 »).
- Deux livrables dans le dépôt :
  - `docs/design/multipiste-scene-v2.html` : le document « multipiste scène v2 ». Fixe le design : maquette
    jouable (ordinateur, iPad portrait, téléphone), anatomie du fader, états ajoutés, plan en 8 étapes.
    Maquette publiée aussi comme artifact : https://claude.ai/artifact/DvAD3JYyFrviZHTiuWAgLW (même contenu).
  - `docs/specs/05-redesign-scene-v2.md` : la spec exhaustive (jetons, dimensions par taille d'écran,
    composants, fader, ondes, écrans, textes, comportements, accessibilité, critères d'acceptation).

### Décisions de Yannick (ne pas rouvrir)

1. Direction **B « Scène »** : dock de transport en bas **inchangé**, accent lime `#c4f24a`, champ de
   recherche toujours visible.
2. Volume de chaque piste **toujours accessible**, fader de console **horizontal** sur ordinateur et iPad ;
   **vertical au bord droit sur téléphone**.
3. Formes d'onde : **tracé naturel de l'app actuelle** (1 px, miroir, normalisé, couleur de piste). Pas de
   barres. Pas d'atténuation de la partie non jouée.
4. Responsive tablette et téléphone obligatoire.
5. Import d'un fichier sans passer par la recherche : bouton dans le champ, dépôt sur la fenêtre, `Ctrl/Cmd + O`.
6. Crête par piste : étape finale **optionnelle**. Pas de maquette téléphone en paysage.

## 2. Le plan des étapes

Chaque étape laisse l'app fonctionnelle et livrable seule. Taille : S ≈ ½ jour, M ≈ 1 jour, L ≈ 2 jours.
Les étapes 1 à 4 améliorent l'écran de lecture sans toucher à l'import, intact jusqu'à l'étape 5.

| # | Étape | Contenu | Spec | Taille | Risque |
|---|-------|---------|------|--------|--------|
| 1 | Jetons de design | Variables CSS (couleurs, rayons, espacements, piles de polices, accent lime), remplacement des anciens noms. Aucun changement visible. | § 2 | S | Faible |
| 2 | Fader et M/S | Composant pointeur (horizontal, et vertical `.ph`) à la place des `<input type="range">`. Boutons M/S redessinés. Loi de console, aimantation 0 dB, clavier, `touch-action: none`. Fader général. | § 4.3, § 5 | M | Tactile iPad : geste contre défilement |
| 3 | Pistes et ondes | Nouvelle ligne de piste (en-tête 268 px, valeur dB, état silencieux), tracé d'onde inchangé en pleine couleur, rendu refait au redimensionnement. | § 3, § 4.3, § 6 | M | Faible |
| 4 | Règle et boucle | Boucle posée sur la règle avec poignées, glisser sur la règle au doigt, A/B tactiles, effacement. Fin de la dépendance à Maj. | § 4.2 | M | Gestes sur la règle |
| 5 | Barre du haut et recherche | Champ unique (titre, lien, filtre), bouton fichier intégré, dépôt sur la fenêtre, `/` et `Ctrl/Cmd + O`, feuille de résultats, jeton d'import et liste des étapes, bannière relais. | § 4.1, § 4.7, § 4.8, § 4.11 | L | Relais, Turnstile et file d'import existants |
| 6 | Dock de transport | Lecture, temps, tonalité, boucle, fader général, « Tout réactiver », crête générale en échelle console. Mêmes fonctions qu'aujourd'hui. | § 4.4 | M | Faible |
| 7 | Bibliothèque et états | Sélecteur de morceau, pochettes, premier lancement, réglages, toasts et bannière de mise à jour restylés. | § 4.1, § 4.6, § 4.9, § 4.10, § 4.12 | M | Faible |
| 8 | Responsive | Points de rupture 700 et 1024 px, fenêtre basse, zones sûres, passe finale sur simulateurs, retrait de la règle qui cache les faders sous 760 px. | § 3 | M | Hauteur sur iPad avec barre Safari |
| + | Crête par piste (optionnel) | `AnalyserNode` par piste après `t.gain`, une seule boucle `requestAnimationFrame`. Sans elle, crête masquée. | § 5.5 | S | Coût CPU sur mobile |

Pendant les étapes 2 à 7, le CSS et le balisage des trois tailles sont écrits **ensemble**, composant par
composant, pas desktop d'abord. L'étape 8 est une passe de réglage et de recette, pas la première fois
qu'on voit le téléphone.

### Entrée et sortie de chaque étape

- **Entrée** : étape précédente fusionnée, recette passée, go de Yannick.
- **Sortie** : (a) comparaison avec le document de design à 1180, 820 et 390 px (spec § 10.1) ; (b) fonctions
  F1–F15 de `03-tests.md` sans régression ; (c) console propre ; (d) captures montrées à Yannick ; (e) pour
  tout rendu marqué **[spec]** dans la spec : validation de Yannick sur captures.

## 3. Branches et fusion

- **Attendre l'intégration de la phase 1.** `phase1-front` modifie `index.html` (≈ +150 lignes : relais même
  origine, lien `#cle`, transfert de bibliothèque). Commencer la refonte avant ferait des conflits sur les mêmes
  zones (`renderPanel`, `renderFooter`, relais).
- Partir de `main` à jour, **une branche par étape** : `redesign-1-tokens`, `redesign-2-fader`, … ou une branche
  `redesign` avec un commit par étape, au choix de Yannick. Le fichier est unique : ne pas faire tourner deux
  étapes en parallèle.
- **Ne jamais pousser sur `main` du front sans l'accord de Yannick** (règle de `00-roadmap.md`). Pousser la
  branche, présenter les captures, attendre le feu vert.
- Surveiller `gh-pages` (copie figée avec émetteur) : le front redessiné ne doit pas y être copié sans accord.

## 4. Routine de recette (chaque étape)

Règle de Yannick : jamais « prêt » sans avoir testé soi-même.

1. Serveur local (port libre, pas 8765) sur `index.html`. Bien vérifier la taille servie (`wc -c`).
2. **Chrome** (Playwright) : 1180 × 820, 820 × 1180, 390 × 844, 360 × 740, 375 × 667 ; console sans erreur ni
   rapport CSP ; captures des vues touchées.
3. **Firefox** et **WebKit** (Playwright) : au moins 1180 et 390.
4. **iPad** : simulateur iPad (`DEVELOPER_DIR`, voir la mémoire « Test Safari iPad ») ; geste du fader, défilement,
   règle, barre Safari.
5. **iPhone** : simulateur iPhone ; fader vertical, zones sûres, feuille de recherche et clavier.
6. Pas d'émulateur Android : contrôle manuel de Yannick à chaque jalon.
7. Cases de `03-tests.md` mises à jour pour les fonctions touchées.
8. Pour l'audio : lecture 6 pistes synchro, mute/solo, volume, boucle, tonalité ; pas de coupure en glissant un fader.

## 5. Pièges connus

| Sujet | Précaution |
|-------|------------|
| Faders et défilement iOS | `touch-action: none`, capture du pointeur, test réel sur simulateur iPad avant de passer à l'étape 3. |
| Rendu des lignes pendant un geste | Ne pas appeler `renderSong` pendant le glissement : écrire `--p` et la valeur, `applyMix()` en `requestAnimationFrame`. |
| Ondes et taille de fenêtre | Les trois mises en page n'ont pas la même largeur utile : refaire le rendu au `resize` (debounce), sinon étirement. |
| Hauteur iPad avec barre Safari | `100dvh`, jamais `100vh` ; tester avec barre visible et masquée. |
| Polices | CSP `font-src 'self'` : piles système par défaut, aucune ressource externe. L'hébergement des polices est hors périmètre. |
| Poids | `index.html` ≈ 89 Ko aujourd'hui, cible < 140 Ko. Surveiller à chaque étape. |
| Maquette contre app | La maquette anime des crêtes **factices** et génère des ondes procédurales : ne pas porter ce code, seulement le CSS et la géométrie. |
| Relais et Turnstile | Le déclenchement de la recherche passe par la logique existante : ne rien changer au protocole ni aux en-têtes. |
| Pochette | Vérifier dans le format de bibliothèque si les noms de pistes sont stockés ; sinon couleurs par défaut. Ne pas modifier le format. |
| Mots de passe, clés | Aucune clé, aucun lien `#cle=` dans les captures ni les commits. |

## 6. Questions ouvertes pour Yannick (à poser au moment de l'étape concernée)

- Étape 4 : le tactile pose la boucle en glissant sur la règle ; la lettre A/B (toucher) et la croix ✕ convient-elle ?
- Étape 5 : emplacement final du bouton « dossier de pistes MP3 » (en bas de la bibliothèque, ou dans la feuille).
- Étape 7 : présentation de la bibliothèque (popover ordinateur, feuille basse téléphone) à valider sur captures.
- Étape 8 : héberger les polices (Inter, Space Grotesk, JetBrains Mono) ou garder les piles système ?
- Fin : fusionner sur `main` quand, et prévenir les amis ?

## 7. Reprise par une nouvelle session

1. Lire `00-roadmap.md`, `03-tests.md`, `05-redesign-scene-v2.md`, ce fichier, puis ouvrir le document de design.
2. Lire la mémoire « Redesign Scène v2 », « Tester avant la recette », « Test Safari iPad ».
3. Confirmer avec Yannick le go et l'étape à lancer. Ne rien coder avant.
4. Modèle conseillé : Sonnet 5.5 / high (code ciblé dans un gros fichier unique, spec précise). Relecture du diff
   par un sous-agent à la fin de chaque étape.
