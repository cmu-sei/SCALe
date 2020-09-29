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

require 'scaife/api/registration'

class ScaifeRegistrationController < ApplicationController
  include Scaife::Api::Registration

  def getLoginModal
    respond_to do |format|
      format.html
      format.js
    end
  end

  def getRegisterModal
    respond_to do |format|
      format.html
      format.js
    end
  end

=begin
  User clicks "Register" button on _getRegisterModal.html.erb
=end
  def submitRegister
    first = params[:firstname_field]
    last = params[:lastname_field]
    org = params[:org_field]
    user = params[:user_field]
    pass = params[:password_field]
    if first.blank? or last.blank? or org.blank? or user.blank? or pass.blank?
      @response_msg = "Please populate all of the fields"
    else
      begin
        response = SCAIFE_register(first, last, org, user, pass)
        @response_code = response.code
        if response.code == 201
          # continue with login
          begin
            login_response = SCAIFE_login(user, pass)
            @login_response_code = login_response.code
            if login_response.code == 200
              connectPulsar()
              session[:login_token] = JSON.parse(login_response.body)["x_access_token"]
              session[:scaife_mode] = "Connected"
            else
              if [400, 405].include? login_response.code
                # Invalid Request or Login Unavailable
                @login_response_msg = login_response.body.gsub('"', '')
              else
                body = JSON.parse(response.body)
                @login_response_msg = "Error #{@login_response_code}: #{body['title']}: #{body['detail']}"
              end
              session.delete(:login_token)
              session.delete(:scaife_mode)
            end
          end
        else
          if [400, 405].include? response.code
            # Invalid Request or Registration Unavailable
            @response_msg = response.body.gsub('"', '')
          else
            # Unknown error
            body = JSON.parse(response.body)
            msg = "Error #{@response_code}: #{body['title']}: #{body['detail']}"
            puts msg
            @response_msg = msg
          end
          session.delete(:login_token)
          session.delete(:scaife_mode)
        end
      rescue Errno::ECONNREFUSED => e
        # SCAIFE servers aren't running
        puts "SCAIFE registration error: #{e.message}"
        if @debug
          @response_msg = e.message
        else
          @response_msg = "Failed to connect to SCAIFE registration server"
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def submitLogin
    user = params[:user_field]
    pass = params[:password_field]
    if user.blank? or pass.blank?
      @response_msg = "Invalid User or Password"
    else
      begin
        response = SCAIFE_login(user, pass)
        @response_code = response.code
        if response.code == 200
          connectPulsar()
          session[:login_token] = JSON.parse(response.body)["x_access_token"]
          session[:scaife_mode] = "Connected"
        else
          if [400, 405].include? response.code
            # Invalid Request # or Login Unavailable
            @response_msg = response.body.gsub('"', '')
          else
            # Unexpected Error
            begin
              body = JSON.parse(response.body)
              if @debug.present?
                @response_msg = "Error #{@response_code}: #{body['title']}: #{body['detail']}"
              else
                @response_msg = body["title"]
              end
            rescue JSON::ParserError
              puts "non-json response: #{response.body}"
              @response_msg = "Failed to connect to SCAIFE registration server"
            end
          end
          session.delete(:login_token)
          session.delete(:scaife_mode)
        end
      rescue Errno::ECONNREFUSED => e
        # SCAIFE servers aren't running
        if @debug
          puts "SCAIFE registration server not running: #{e.message}"
          @response_msg = e.message
        else
          @response_msg = "Failed to connect to SCAIFE registration server"
        end
        session.delete(:login_token)
        session[:scaife_mode] = "Demo"
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def submitLogout
    begin
      r_token = rand 100..999
      response = SCAIFE_logout(session[:login_token], r_token)
      @response_code = response.code
      if response.code == 200
        disconnectPulsar()
        @response_msg = "User Successfully Logged Out"
      else
        if [400, 405].include? response.code
          # Invalid Request or Logout Unavailable
          @response_msg = response.body.gsub('"', '')
        else
          # Unknown Error
          body = JSON.parse(response.body)
          msg = "Error #{@response_code}: #{body['title']}: #{body['detail']}"
          puts msg
          if @debug.present?
            @response_msg = msg
          else
            @response_msg = "Problem with SCAIFE registration server"
          end
        end
        self._clear_scaife_session()
      end
    rescue Errno::ECONNREFUSED => e
      # SCAIFE registration server isn't running
      if @debug
        puts "SCAIFE registration server not running: #{e.message}"
        @response_msg = e.message
      else
        @response_msg = "SCAIFE registration server offline"
      end
    ensure
      self._clear_scaife_session()
    end
    respond_to do |format|
      format.js
    end
  end

  def connectPulsar
    script = Rails.root.join('scripts/connect_to_pulsar.sh')
    spawn("#{script} pulsar")
  end

  def disconnectPulsar
    %w[stats_subscriber connect_to_pulsar].each do |pgm|
      path = Rails.root.join("tmp/#{pgm}.pid")
      Process.kill('TERM', open(path).read.to_i)
      File.delete(path)
    end
  rescue Errno::ESRCH
  ensure
    puts('Pulsar disconnected')
  end
end
