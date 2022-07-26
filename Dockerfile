FROM continuumio/anaconda3
RUN apt update && \
apt-get install ffmpeg libsm6 libxext6 unzip wget -y

RUN conda create -n py39 python=3.9 pip
RUN echo "source activate py39" > ~/.bashrc

WORKDIR /app

COPY endpoints.js .

RUN git clone https://github.com/microsoft/landcover.git && \
wget -O landcover.zip "https://mslandcoverstorageeast.blob.core.windows.net/web-tool-data/landcover.zip" && \
unzip -q landcover.zip && \
rm landcover.zip && \
cd landcover/data/basemaps && \
unzip -q hcmc_sentinel_tiles.zip && \
unzip -q m_3807537_ne_18_1_20170611_tiles.zip && \
rm *.zip && \
cd ../../../ && \
cp landcover/web_tool/datasets.json landcover/web_tool/datasets.mine.json && \
cp landcover/web_tool/models.json landcover/web_tool/models.mine.json && \
cp endpoints.js landcover/web_tool/endpoints.mine.js


WORKDIR /app/landcover
ENV PATH /opt/conda/envs/landcover/bin:$PATH
RUN set -x && \
    /opt/conda/bin/conda config --append channels pytorch && \
    /opt/conda/bin/conda config --append channels conda-forge && \
    /opt/conda/bin/conda config --remove channels "defaults" && \
    /opt/conda/bin/conda env create --file environment_precise.yml python=3.9 && \
    /opt/conda/bin/conda run -n landcover pip install opencv-python


SHELL ["conda", "run", "-n", "landcover", "/bin/bash", "-c"]
EXPOSE 8080
ENTRYPOINT ["conda", "run", "-n", "landcover", "python", "server.py"]