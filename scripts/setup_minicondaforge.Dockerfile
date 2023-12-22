
FROM docker.io/fedora:38

COPY setup_minicondaforge.sh /setup_minicondaforge.sh
RUN /setup_minicondaforge.sh
