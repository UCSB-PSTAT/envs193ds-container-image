FROM ucsb/rstudio-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

ENV TZ America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN conda install -y \
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
    r-skimr\
    r-wesanderson

RUN R -e "devtools::install_github('Ryo-N7/tvthemes', 'gadenbuie/ggpomological')"

RUN R -e "install.packages(c('lterdatasampler', 'NatParksPalettes'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN /usr/local/bin/fix-permissions "${CONDA_DIR}" || true


USER $NB_USER

