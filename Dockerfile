# Front de mini webdaw : un seul fichier statique servi par nginx (utilisateur non root, port 8080).
# Image multi-arch (amd64, arm64…) figée par version et empreinte : à mettre à jour à la main.
FROM nginxinc/nginx-unprivileged:1.30.6-alpine@sha256:f5116ed4606f3eb015dd4a8e28cb9b351476dc0ad4bc6e9f93b19cec130cdf03

# Retire la page d'accueil et le site par défaut de l'image : seul index.html est servi.
USER root
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/default.conf
USER 101

COPY nginx.conf /etc/nginx/nginx.conf
# Uniquement la page : jamais lab/, docs/, DOC.md ni .git (voir aussi .dockerignore).
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
