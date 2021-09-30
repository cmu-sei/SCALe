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
FROM ubuntu:bionic

ARG SCAIFE_MODE=""
ARG RAILS_ENV=""

## First install packages that don't depend on SCALe

# Apt packages
RUN apt-get -q update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y install --no-install-recommends \
           autoconf build-essential sqlite3 sqlite3-pcre wget zip \
           unzip python python-pip python-dev tzdata libncurses5-dev \
           libssl-dev libsqlite3-dev ruby ruby-dev ca-certificates \
           libffi-dev libssl-dev libyaml-dev procps zlib1g-dev \
           global curl git \
    && apt-get -q --purge -y autoremove \
    && apt-get -q clean

# note: pip upgrade required for optimal grpcio install
RUN pip install -q --no-cache-dir --upgrade pip

# Pandoc
RUN wget --no-verbose https://github.com/jgm/pandoc/releases/download/2.6/pandoc-2.6-1-amd64.deb \
    && dpkg -i pandoc-2.6-1-amd64.deb \
    && rm pandoc-2.6-1-amd64.deb

# Bundler
RUN gem update -q --system \
    && gem install -q json_pure bundler:2.1.4

ARG PRODUCTION=0
# Loads all testing, unless production version
RUN if [ "$PRODUCTION" -eq "0" ]; then \
        apt-get -q update \
        && DEBIAN_FRONTEND=noninteractive apt-get -q -y install --no-install-recommends \
               pylint python-pytest python-pytest-cov linkchecker \
               firefox openjdk-8-jdk-headless maven \
        && apt-get -q clean \
        && wget --no-verbose https://github.com/mozilla/geckodriver/releases/download/v0.27.0/geckodriver-v0.27.0-linux64.tar.gz \
        && tar -zxvf geckodriver-v0.27.0-linux64.tar.gz -C /usr/local/bin/ \
        && rm -rf geckodriver-v0.27.0-linux64.tar.gz; \
    fi


## Now SCALe workdir & user. Don't copy anything yet
ENV SCALE_HOME=/
ENV SCALE_APP_DIR=/scale
WORKDIR $SCALE_APP_DIR
RUN ln -s $SCALE_APP_DIR /scale.app

# propagate test mode from ARG
ENV SCAIFE_MODE=$SCAIFE_MODE
ENV RAILS_ENV=$RAILS_ENV

ARG USECERT
ENV E_USECERT=$USECERT

# grab external python requirements
COPY requirements.txt $SCALE_APP_DIR
RUN pip install -q -r requirements.txt

# Loads up Maven test infrastructure (without running actual tests)
COPY test/junit/test/pom.xml ./test/junit/test/pom.xml
RUN if [ "$PRODUCTION" -eq "0" ]; then \
        cd ./test/junit/test && \
        #mvn --batch-mode dependency:go-offline || \
        mvn -q --batch-mode "-Dtest=TestWebAppCoreScenariosLocal#testNone" test || \
        echo yes ; \
    fi

## Now do builds that depend on bits of SCALe.

# Add bundled gems
COPY Gemfile Gemfile.lock   ./
RUN bundle config set path ./vendor/bundle && bundle install --quiet --jobs 8

# Add everything else
COPY . $SCALE_APP_DIR

RUN ./init.sh

EXPOSE 8083

# needs ENV RAILS_ENV
CMD ["/scale/start.sh"]
