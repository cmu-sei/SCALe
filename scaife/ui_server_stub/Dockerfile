# <legal>
# SCALe version r.6.7.0.0.A
# 
# Copyright 2021 Carnegie Mellon University.
# 
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
# INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
# UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
# IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
# FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
# OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
# MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
# TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# 
# Released under a MIT (SEI)-style license, please see COPYRIGHT file or
# contact permission@sei.cmu.edu for full terms.
# 
# [DISTRIBUTION STATEMENT A] This material has been approved for public
# release and unlimited distribution.  Please see Copyright notice for
# non-US Government use and distribution.
# 
# DM19-1274
# </legal>

FROM ubuntu:focal

RUN apt-get -q update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y install --no-install-recommends git \
    universal-ctags python3 python3-pip python3-wheel redis-server unzip mongo-tools wget \
    && apt-get -q clean
RUN pip3 install -q --no-cache-dir --upgrade pip && \
    pip3 install -q --no-cache-dir setuptools && \
    pip3 install -q --no-cache-dir flask_cors tox wheel

RUN mkdir -p /usr/src \
    && cd /usr/src \
    && wget --no-verbose https://github.com/swagger-api/swagger-codegen/archive/master.zip \
    && unzip -q master.zip \
    && rm master.zip

ENV SERVER=/usr/src/app
ENV PORT=8088

ENV SRCLIB=swagger_server/rapidclass_scripts/src/rclib
ENV RCLIBDIR=swagger_server/rapidclass_scripts/src/rclib/rclib
ENV STATSDIR=swagger_server/rapidclass_scripts/src/rclib/rclib/stats
ENV PYTHONPATH=$SERVER/$SRCLIB:$SERVER/$RCLIBDIR:$SERVER/$STATSDIR

WORKDIR $SERVER

ARG USECERT=""
ENV E_USECERT=$USECERT

# Running tox installs requirements, in a place tox requires.
COPY requirements.txt test-requirements.txt setup.py tox.ini init.sh $SERVER/
RUN ./init.sh

COPY . $SERVER

EXPOSE $PORT

ENTRYPOINT ["python3"]

CMD ["-m", "swagger_server"]
