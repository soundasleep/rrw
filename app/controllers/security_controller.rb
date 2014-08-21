class SecurityController < ApplicationController
  def redirect_uri
    'http://localhost:3000/security/oauth2callback'
  end

  def client
    require 'oauth2'

    if Rails.env == "development"
      OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
    end

    client_id = '946722529018-k9qfuast1j4ld84sqqsqrc08g883mlt2.apps.googleusercontent.com'
    client_secret = '0t40pjkcp4lF9QumwN3L0Zpg'

    # site = "https://accounts.google.com/o/oauth2/auth"
    # site = "https://accounts.google.com/o/oauth2/auth?scope=openid%20email"
    site = "https://accounts.google.com"

    return OAuth2::Client.new(client_id, client_secret, :site => site, :authorize_url => "/o/oauth2/auth", :token_url => "/o/oauth2/token")
  end

  def login
    @url = client.auth_code.authorize_url(:redirect_uri => redirect_uri, :scope => "openid email")
    redirect_to(@url)
  end

  def oauth2callback
    begin
      code = params[:code]
      @token = client.auth_code.get_token(code, :redirect_uri => redirect_uri)

      # redirect_to("/security/success")
      render "success"
    rescue OAuth2::Error
      redirect_to("/security/login")
    end
  end

  def success
  end
end
