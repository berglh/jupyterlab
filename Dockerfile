# Pyspark

FROM jupyter/pyspark-notebook:latest
LABEL maintainer="Berg Lloyd-Haig <berg@uq.edu.au>"

USER root

# You can revert to JRE8 to avoid errors on Pyspark load (Reflection Errors)
# RUN apt-get update && apt-get purge -y openjdk-11-jre-headless && apt-get install -y openjdk-8-jre-headless curl && apt-get -y autoremove && apt-get clean
# othwerise, just cleanup apt in case
RUN apt-get -y autoremove && apt-get clean

# add logging config, removes excessive warnings messages from notebooks
ADD files/log4j.properties /usr/local/spark/conf

# configure for jovyan
RUN printf 'jovyan    ALL=(ALL:ALL) ALL' >> /etc/sudoers.d/jovyan

# set default jovyan password as jupyter:  echo 'jupyter' | openssl passwd -5 -stdin
RUN printf 'jovyan:$5$evQjlKuZj$VfwL7JB8vTC7MFW6Zvo7OzPk3aXSnRiPST77ogUOnk/' | chpasswd --encrypted

# change back to jovyan user
USER ${NB_UID}

# install and upgrade jupyterlab extensions
RUN pip install --upgrade 'jupyterlab>=3' 'jupyterlab_server' 'pyspark' 'plotly'

# instal spark monitor for spark session UI integreation to notebook
RUN pip install jupyterlab-sparkmonitor plotly
RUN ipython profile create --ipython-dir=/home/${NB_USER}/.ipython
RUN echo "c.InteractiveShellApp.extensions.append('sparkmonitor.kernelextension')" >> /home/${NB_USER}/.ipython/profile_default/ipython_config.py

# plotly needs a lab extension also
RUN jupyter labextension install jupyterlab-plotly

# this rebuiltd jupyter lab to register extensions correctly
RUN jupyter lab build