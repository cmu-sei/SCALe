=begin
#SCAIFE Registration and Login Module API Definition

# This file contains API client code in Ruby, generated from the SCAIFE
# registration module's API definition. SCAIFE facilitates auditing
# static analysis meta-alerts using classifiers, optional adaptive
# heuristics, and meta-alert prioritization. SCAIFE enables
# jump-starting labeled datasets using test suites. It is intended to
# enable a wide range of users (with widely varying datasets, static
# analysis tools, machine learning expertise, and amount of labeled
# data) to benefit from using classifiers and sophisticated
# prioritization to automatically triage static analysis meta-alerts.
#
# Generated by: https://openapi-generator.tech
# OpenAPI Generator version: 5.0.0
#
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

=end

# Common files
require_relative 'registration/api_client'
require_relative 'registration/api_error'
require_relative 'registration/version'
require_relative 'registration/configuration'

# Models
require_relative 'registration/models/access_token'
require_relative 'registration/models/login_credentials'
require_relative 'registration/models/user_information'

# APIs
require_relative 'registration/api/registration_server_api'
require_relative 'registration/api/ui_to_registration_api'

module Scaife
module Api
module Registration

  class << self
    # Customize default settings for the SDK using block.
    #   Scaife::Api::Registration.configure do |config|
    #     config.username = "xxx"
    #     config.password = "xxx"
    #   end
    # If no block given, return the default Configuration object.
    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end
  end

end
end
end
