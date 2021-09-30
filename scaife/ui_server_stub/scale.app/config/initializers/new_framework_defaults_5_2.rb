# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.2 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

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

# Make Active Record use stable #cache_key alongside new #cache_version method.
# This is needed for recyclable cache keys.
# Rails.application.config.active_record.cache_versioning = true

# Use AES-256-GCM authenticated encryption for encrypted cookies.
# Also, embed cookie expiry in signed or encrypted cookies for increased security.
#
# This option is not backwards compatible with earlier Rails versions.
# It's best enabled when your entire app is migrated and stable on 5.2.
#
# Existing cookies will be converted on read then written with the new scheme.
# Rails.application.config.action_dispatch.use_authenticated_cookie_encryption = true

# Use AES-256-GCM authenticated encryption as default cipher for encrypting messages
# instead of AES-256-CBC, when use_authenticated_message_encryption is set to true.
# Rails.application.config.active_support.use_authenticated_message_encryption = true

# Add default protection from forgery to ActionController::Base instead of in
# ApplicationController.
# Rails.application.config.action_controller.default_protect_from_forgery = true

# Store boolean values are in sqlite3 databases as 1 and 0 instead of 't' and
# 'f' after migrating old data.
# Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true

# Use SHA-1 instead of MD5 to generate non-sensitive digests, such as the ETag header.
Rails.application.config.active_support.use_sha1_digests = true

# Make `form_with` generate id attributes for any generated HTML tags.
# Rails.application.config.action_view.form_with_generates_ids = true
