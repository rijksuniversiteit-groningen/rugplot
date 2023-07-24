FROM rocker/binder:4.2.0

## Declares build arguments
ARG NB_USER
ARG NB_UID

COPY --chown=${NB_USER} . ${HOME}

ENV DEBIAN_FRONTEND=noninteractive
USER root

RUN echo "Checking for 'apt.txt'..." \
    ; if test -f "apt.txt" ; then \
    apt-get update --fix-missing > /dev/null\
    && xargs -a apt.txt apt-get install --yes \
    && apt-get clean > /dev/null \
    && rm -rf /var/lib/apt/lists/* \
    && wget -qO- \
      "https://yihui.org/tinytex/install-unx.sh" | \
      sh -s - --admin --no-path \
    && mv ~/.TinyTeX /opt/TinyTeX \
    && /opt/TinyTeX/bin/*/tlmgr path add \
    && tlmgr install metafont mfware inconsolata tex ae parskip listings pgf preview grfext \
    && tlmgr install standalone luatex85 pgfplots\
    && tlmgr path add \
    && chown -R root:staff /opt/TinyTeX \
    && chmod -R g+w /opt/TinyTeX \
    && chmod -R g+wx /opt/TinyTeX/bin \
    ; fi

RUN sed -i 's/256MiB/2GiB/' /etc/ImageMagick-6/policy.xml
USER ${NB_USER}

## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi
