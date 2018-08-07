# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

bundle install --path vendor/bundle
bundle exec rake db:migrate
git submodule init
git submodule update
