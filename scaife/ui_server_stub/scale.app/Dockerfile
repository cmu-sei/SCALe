# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
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

## First install packages that don't depend on SCALe

# Apt packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
           autoconf build-essential sqlite3 sqlite3-pcre wget zip \
           unzip python python-pip python-dev tzdata libncurses5-dev \
           libssl-dev libsqlite3-dev ruby ruby-dev ca-certificates \
           libffi-dev libssl-dev libyaml-dev procps zlib1g-dev curl \
    && apt-get --purge -y autoremove \
    && apt-get clean

RUN pip install --no-cache-dir --upgrade pip

# GNU Global
RUN mkdir -p /opt/global \
    && cd /opt/global \
    && wget https://ftp.gnu.org/pub/gnu/global/global-6.5.1.tar.gz \
    && tar -xzf global-6.5.1.tar.gz \
    && rm global-6.5.1.tar.gz \
    && cd global-6.5.1 \
    && autoconf \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf global-6.5.1 \
    && apt-get --purge -y autoremove autoconf \
    && apt-get clean

# Pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/2.6/pandoc-2.6-1-amd64.deb \
    && dpkg -i pandoc-2.6-1-amd64.deb \
    && rm pandoc-2.6-1-amd64.deb

# Bundler
RUN gem update --system \
    && gem install json_pure bundler

ARG PRODUCTION=0
# Loads all testing, unless production version
RUN if [ "$PRODUCTION" -eq "0" ]; then \
        apt-get update \
        && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
               pylint python-pytest python-pytest-cov linkchecker \
               firefox openjdk-8-jdk-headless maven \
        && apt-get clean \
        && wget https://github.com/mozilla/geckodriver/releases/download/v0.27.0/geckodriver-v0.27.0-linux64.tar.gz \
        && tar -zxvf geckodriver-v0.27.0-linux64.tar.gz -C /usr/local/bin/ \
        && rm -rf geckodriver-v0.27.0-linux64.tar.gz; \
    fi


## Now SCALe workdir & user. Don't copy anything yet
ENV SCALE_HOME=/
ENV SCALE_APP_DIR=/scale
WORKDIR $SCALE_APP_DIR
RUN ln -s $SCALE_APP_DIR /scale.app

# grab external python requirements
COPY requirements.txt $SCALE_APP_DIR
RUN pip install -r requirements.txt


## Now do builds that depend on bits of SCALe.

# Add bundled gems
COPY Gemfile Gemfile.lock   ./
RUN bundle config set path ./vendor/bundle \
    && bundle install --jobs 8

# Initialize database
COPY Rakefile   ./
COPY config   ./config/
COPY scripts/init_shared_tables.py scripts/bootstrap.py \
     scripts/languages.json  scripts/tools.json scripts/taxonomies.json \
     ./scripts/
COPY scripts/data/conditions   scripts/data/conditions/
COPY scripts/data/properties   scripts/data/properties/
COPY db   ./db/
RUN    bundle exec rake db:migrate \
    && bundle exec rake db:schema:load \
    && bundle exec rake db:seed

# Add manual & store outside scale.app
COPY doc ./doc
COPY scripts/builddocs.sh ./scripts/builddocs.sh
RUN ./scripts/builddocs.sh

# don't pre-initialize; already done above
# COPY init.sh  ./
# RUN ./init.sh

## Add everything else

COPY .  $SCALE_APP_DIR

# This volume should link to the host's ~/.m2 settings
# VOLUME /home/scale/.m2

EXPOSE 8083

CMD ["/scale/start.sh"]
