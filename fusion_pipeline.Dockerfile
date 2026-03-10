FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       wget \
       ca-certificates \
       bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p ${CONDA_DIR} \
    && rm -f /tmp/miniconda.sh

# Create a dedicated env with pinned tool versions (no mamba required at runtime)
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r \
    && rm -f ${CONDA_DIR}/conda-meta/pinned \
    && conda config --remove-key channels || true \
    && conda config --add channels conda-forge \
    && conda config --add channels bioconda \
    && conda config --set channel_priority flexible \
    && conda create -y -n fusion \
       python=3.10.2 \
       samtools=1.13 \
       bedtools=2.29.2 \
       r-tidyverse=1.3.1 \
       bioconductor-iranges=2.28.0 \
       novoalign=3.09.00 \
       r-optparse=1.7.3 \
    && conda clean -afy

ENV PATH=${CONDA_DIR}/envs/fusion/bin:${CONDA_DIR}/bin:${PATH}

WORKDIR /workspace

CMD ["Rscript", "scripts/fusion_validation_pipeline.R"]
