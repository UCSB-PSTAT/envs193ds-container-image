FROM ucsb/rstudio-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

ENV TZ America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mamba install -c conda-forge \
    r-aiccmodavg \
    r-corrplot \
    r-dharma \
    r-flextable \
    r-ggally \
    r-ggeffects \
    r-glmmtmb \
    r-hmisc\
    r-janitor \
    r-magick \
    r-mumin \
    r-naniar \
    r-palmerpenguins \
    r-performance \
    r-plotly \
    r-skimr \
    r-wesanderson

RUN R -e "install.packages(c('lterdatasampler', 'NatParksPalettes'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN /usr/local/bin/fix-permissions "${CONDA_DIR}" || true


USER $NB_USER

