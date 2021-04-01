# -*- coding: utf-8 -*-

# <legal>
# SCALe version r.6.5.5.1.A
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

# This file defines a base class for the SCAIFE controllers

class ScaifeController < ApplicationController

  attr_accessor :scaife_response
  attr_accessor :scaife_status_code

  def errors
    @errors ||= []
  end

  def maybe_json_response(item)
    # this typically just gets rid of quote marks from around string
    # responses, if present, or extracts the "detail" portion out of a
    # structured error response
    if item.nil?
      item = ""
    else
      begin
        item = JSON.parse(item)
      rescue JSON::ParserError
      end
    end
    if item.is_a?(Hash) and item.include?("detail")
      # error response
      item = item["detail"]
    end
    return item
  end

  def symbolize_data(item)
    # Deep-convert all hash keys to symbols.
    #
    # Why: If you're running data structures through the API models for
    # validation (either as received data outside of a 200 response, or
    # during client-side validation before sending), the validation does
    # not happen with new() but does happen with build_from_hash().
    # Furthermore, build_from_hash() will ignore hash keys that are
    # strings as opposed to symbols -- so this routine can be used to
    # perform a deep-conversion of all string hash keys to symbol keys
    # prior to instantiating the API model from the data.
    #
    # Note: the symbolize_keys() method of hashes does not cascade
    # through embedded hashes, hence this round-trip through JSON.
    if not item.nil?
      item = JSON.parse(item.to_json, symbolize_names: true)
    end
    return item
  end

end
