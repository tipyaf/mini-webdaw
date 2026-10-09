# mini webdaw

Lecteur multipistes (stems) pour répéter : pistes MP3 lues en synchro avec mute / solo / volume en dB, boucle A-B, transposition et limiteur.

**En ligne :** https://tipyaf.github.io/mini-webdaw/

Un seul fichier `index.html`, sans build. Fonctionne aussi en local (`file://`).

1. Ouvrir la page.
2. **Choisir le dossier mp3…** → un dossier contenant un sous-dossier par chanson, fichiers nommés `<titre> (<Instrument>).mp3`.
3. Cliquer une chanson.

Les fichiers audio restent sur l'appareil : rien n'est envoyé au serveur.

Documentation complète : [DOC.md](DOC.md).

## Déploiement

GitHub Pages publie la branche `main` (racine) : chaque push sur `main` met la page à jour (~1 min).
