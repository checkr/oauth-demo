require 'sinatra'
require 'tilt/erb'

CHECKR_CLIENT_ID        = 'XX'
CHECKR_CLIENT_SECRET    = 'XX'
CHECKR_REDIRECT_URL     = 'https://localhost:9292/oauth_callback'
CHECKR_AUTHORIZE_URL    = 'http://dashboard.checkr.dev/oauth/authorize'
CHECKR_DEAUTHORIZE_URL  = 'http://api.checkr.dev/oauth/deauthorize'
CHECKR_TOKENS_URL       = 'http://api.checkr.dev/oauth/tokens'
CHECKR_CANDIDATES_URL   = 'http://api.checkr.dev/v1/candidates'

class DemoApp < Sinatra::Base
  enable :sessions

  get '/' do
    if session['access_token']
      @headers = %w(id uri first_name last_name dob email report_ids)
      @candidates = HTTParty.get(
        CHECKR_CANDIDATES_URL,
        basic_auth: { username: session["access_token"], password: nil }
      )['data']
    end

    erb :index, layout: :layout
  end

  get '/oauth_callback' do
    code = params[:code]

    response = HTTParty.post(CHECKR_TOKENS_URL, body: {
      code: code,
      client_id: CHECKR_CLIENT_ID,
      client_secret: CHECKR_CLIENT_SECRET
    })

    session["access_token"] = response['access_token']

    redirect to('/')
  end

  get '/deauthorize' do
    HTTParty.post(
      CHECKR_DEAUTHORIZE_URL,
      basic_auth: { username: session["access_token"], password: nil }
    )

    redirect to('/')
  end
end
