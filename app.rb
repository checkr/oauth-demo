require 'sinatra'
require 'tilt/erb'

CHECKR_CLIENT_ID     = 'XX'
CHECKR_CLIENT_SECRET = 'XX'
CHECKR_REDIRECT_URL  = 'http://localhost:9292/oauth/callback'
CHECKR_AUTHORIZE_URL = 'https://dashboard.checkr.com/oauth/authorize'
CHECKR_TOKENS_URL    = 'https://api.checkr.com/oauth/tokens'
CHECKR_REPORTS_URL   = 'https://api.checkr.com/v1/reports'

get '/' do
  erb :index, layout: :layout
end

get '/oauth_callback' do
  code = params[:code]
  response = HTTParty.post(CHECKR_TOKENS_URL, body: {
    code: code,
    client_id: CHECKR_CLIENT_ID,
    client_secret: CHECKR_CLIENT_SECRET
  })

  token = response.body['token']

  reports = HTTParty.get(CHECKR_REPORTS_URL)

  erb :reports, layout: :layout, reports: reports.body
end
