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

class UsersController < ScaifeController

  def unauthorized
    respond_to do |format|
      format.html
      format.json
    end
  end

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

  def _handle_login(user, pass)
    # called in submitLogin() as well as submitRegister()
    # returns: response_data, code, code_is_known, response message
    response_msg = userid = nil
    if user.blank? or pass.blank?
      response_msg = "Please fill all available fields"
    else
      userid = User.authenticate(user, pass)
      if userid.nil?
        response_msg = "Authentication failed"
      else
        response_msg = "OK"
      end
    end
    return response_msg, userid
  end

=begin
  User clicks "Register" button on _getRegisterModal.html.erb
=end
  def submitRegister
    session[:login_user] = nil
    first = params[:firstname_field]
    last = params[:lastname_field]
    org = params[:org_field]
    username = params[:user_field]
    pass = params[:password_field]
    @user_response = @user_login_response = nil
    @user_status_code = @user_login_status_code = nil
    if first.blank? or last.blank? or org.blank? or username.blank? or pass.blank?
      @user_response = "Please populate all of the fields"
    else
      # continue with login
      User.create(first, last, org, username, pass).save!

      @user_login_response, session[:login_user_id] = _handle_login(username, pass)
      if @user_login_response == "OK"
        @user_status_code = 201
        @user_login_status_code = 200
        session[:login_user] = username
      else
        @user_status_code = 201
        session[:login_user] = nil
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def submitLogin
    user = params[:user_field]
    pass = params[:password_field]
    @user_response, session[:login_user_id] = _handle_login(user, pass)
    if @user_response == "OK"
      session[:login_user] = user
      @user_status_code = 200
    else
      session[:login_user] = nil
      @user_status_code = 202
    end
    respond_to do |format|
      format.js
    end
  end

  def submitLogout
    session[:login_user] = nil
    @user_status_code = @user_response = nil
    respond_to do |format|
      format.js
    end
  end

end
