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

require 'scaife/api/registration'

class ScaifeRegistrationController < ScaifeController

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

  def get_server_access(server, login_token, silent: false)
    if login_token.blank?
      raise ScaifeAccessError.new("no token present")
    end
    begin
      api = Scaife::Api::Registration::UIToRegistrationApi.new
      response, status_code, headers = \
        api.get_server_access_with_http_info(server, login_token)
      if status_code != 200
        puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
        response = "Unknown Result"
      end
    rescue Scaife::Api::Registration::ApiError => e
      status_code = e.code
      if [400, 404, 405].include? e.code
        # Invalid Request, not found, etc
        response = maybe_json_response(e.response_body)
        if login_token.present? and not silent
          puts "defined server access fail: #{e}"
          puts login_token
        end
      else
        # Unknown error
        puts "\nException #{__method__} calling UIToRegistrationApi->get_server_access: #{e}\n"
        response = "Error #{e.code}: #{e}"
      end
    end
    return response, status_code
  end

  def _handle_login(user, pass)
    # called in submitLogin() as well as submitRegister()
    # returns: response_data, code, code_is_known, response message
    code = nil
    code_is_known = false
    data = nil
    response_msg = nil
    if user.blank? or pass.blank?
      return code, code_is_known, data, response_msg
    end
    begin
      query_data = Scaife::Api::Registration::LoginCredentials.build_from_hash({
        username: user,
        password: pass
      })
      api = Scaife::Api::Registration::UIToRegistrationApi.new
      data, code, headers = \
        api.login_user_with_http_info(query_data)
      if code == 200
        code_is_known = true
        response_msg = "OK"
      else
        # these shouldn't happen
        code_is_known = false
        response_msg = "Unknown Result"
        puts "Unknown result in #{__method__}: #{code}: #{data}"
      end
    rescue Scaife::Api::Registration::ApiError => e
      code = e.code
      if [400, 405].include? e.code
        # Invalid Request or Login Unavailable
        code_is_known = true
        response_msg = maybe_json_response(e.response_body)
      else
        # Unexpected Error
        puts "\nException #{__method__} calling UIToRegistrationApi->login_user: #{e}\n"
        code_is_known = false
        if e.message.include? "resolve host name" 
          response_msg = "SCAIFE servers not found"
        else
          response_msg = "Unknown Error"
        end
      end
    end
    return data, code, code_is_known, response_msg
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
    @scaife_response = @scaife_login_response = nil
    @scaife_status_code = @scaife_login_status_code = nil
    if first.blank? or last.blank? or org.blank? or user.blank? or pass.blank?
      @scaife_response_msg = "Please populate all of the fields"
    else
      begin
        query_data = Scaife::Api::Registration::UserInformation.build_from_hash({
          first_name: first,
          last_name: last,
          organization_name: org,
          username: user,
          password: pass
        })
        api = Scaife::Api::Registration::UIToRegistrationApi.new
        @scaife_response, @scaife_status_code, response_headers = \
          api.register_users_with_http_info(query_data)
        if @scaife_status_code == 201
          # continue with login
          login_data, @scaife_login_status_code, code_is_known, \
            @scaife_login_response = _handle_login(user, pass)
          if @scaife_login_status_code == 200
            connectPulsar()
            session[:login_token] = login_data.x_access_token
            session[:scaife_mode] = "Connected"
          else
            _clear_scaife_session()
          end
        else
          # only other 2?? codes would show up here, so shouldn't happen
          # these shouldn't happen
          puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
          @scaife_response = "Unknown Result"
          _clear_scaife_session()
        end
      rescue Scaife::Api::Registration::ApiError => e
        @scaife_status_code = e.code
        if [400, 405].include? e.code
          # Invalid Request or Registration Unavailable
          @scaife_response = maybe_json_response(e.response_body)
        else
          # Unexpected Error
          puts "\nException #{__method__} calling UIToRegistrationApi->register_users: #{e}\n"
          if e.message.include? "resolve host name" 
            @scaife_response = "SCAIFE servers not found"
          else
            @scaife_response = "Unknown Error"
          end
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
    response_data, @scaife_status_code, code_is_known, @scaife_response =
      _handle_login(user, pass)
    if @scaife_status_code == 200
      connectPulsar()
      session[:login_token] = response_data.x_access_token
      session[:scaife_mode] = "Connected"
    else
      _clear_scaife_session()
    end
    respond_to do |format|
      format.js
    end
  end

  def submitLogout
    @scaife_status_code = @scaife_response = nil
    begin
      begin
        api = Scaife::Api::Registration::UIToRegistrationApi.new
        if session[:login_token].present?
            response_dta, @scaife_status_code, response_headers = \
                api.logout_user_with_http_info(session[:login_token])
          if @scaife_status_code == 200
            @scaife_response = "User Successfully Logged Out"
          else
            # Unknown 2?? response...
            puts "error in #{__method__}: #{@scaife_status_code}: #{response_dta}"
            @scaife_response = "Problem with SCAIFE registration server"
          end
        else
          puts "not logged in, no token present"
          @scaife_response = "Not logged in"
        end
      rescue Scaife::Api::Registration::ApiError => e
        @scaife_status_code = e.code
        if [400, 405].include? e.code
          # Invalid Request or Logout Unavailable
          @scaife_response = maybe_json_response(e.response_body)
        elsif session[:login_token].blank?
          @scaife_response = "User not logged on"
        else
          # Unexpected Error
          puts "\nException #{__method__} calling UIToRegistrationApi->logout_users: #{e.message}\n"
          @scaife_response = "Problem with SCAIFE registration server"
        end
      end
    ensure
      self._clear_scaife_session()
      disconnectPulsar()
    end
    respond_to do |format|
      format.js
    end
  end

  def connectPulsar
    if not self.offline_testing
      script = Rails.root.join('scripts/connect_to_pulsar.sh')
      spawn("#{script} pulsar")
    end
  end

  def disconnectPulsar
    %w[stats_subscriber connect_to_pulsar].each do |pgm|
      path = Rails.root.join("tmp/#{pgm}.pid")
      if File.exist? path
        Process.kill('TERM', open(path).read.to_i)
        File.delete(path)
      end
    end
  rescue Errno::ESRCH
  ensure
    puts('Pulsar disconnected')
  end

end
