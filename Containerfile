FROM registry.cloud.college.ucsb.edu/ucsb/rstudio-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

ENV TZ America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mamba install -y -c conda-forge\
    r-aiccmodavg\
    r-corrplot\
    r-dharma\
    r-effectsize\
    r-flextable\
    r-ggally\
    r-gganimate\
    r-ggeffects\
    r-gghighlight\
    r-ggimage\
    r-ggthemes\
    r-glmmtmb\
    r-gtsummary\
    r-here\
    r-hmisc\
    r-janitor\
    r-magick\
    r-modelsummary\
    r-mumin\
    r-naniar\
    r-paletteer\
    r-palmerpenguins\
    r-performance\
    r-plotly\
    r-rstatix \
    r-skimr\
    r-wesanderson &&\
    mamba clean -afy &&\
    /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

RUN Rscript -e "pak::pak('Ryo-N7/tvthemes')" &&\
    Rscript -e "pak::pak('gadenbuie/ggpomological')" &&\
    Rscript -e "install.packages(c('lterdatasampler', 'NatParksPalettes'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())" &&\
    /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

USER $NB_USER
