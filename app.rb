require 'sinatra'
require 'tilt/erb'
require 'dotenv'
Dotenv.load

class DemoApp < Sinatra::Base
  enable :sessions

  get '/' do
    if session['access_token']
      @headers = %w(id uri first_name last_name dob email report_ids)
      @candidates = HTTParty.get(
        ENV['CHECKR_API'] + ENV['CHECKR_CANDIDATES_URL'],
        basic_auth: { username: session["access_token"], password: nil }
      )['data']
    end

    erb :index, layout: :layout
  end

  get '/oauth_callback' do
    code = params[:code]

    response = HTTParty.post(ENV['CHECKR_API'] + ENV['CHECKR_TOKENS_URL'], body: {
      code: code,
      client_id: ENV['CHECKR_CLIENT_ID'],
      client_secret: ENV['CHECKR_CLIENT_SECRET']
    })

    session["access_token"] = response['access_token']

    redirect to('/')
  end

  get '/deauthorize' do
    HTTParty.post(
      ENV['CHECKR_API'] + ENV['CHECKR_DEAUTHORIZE_URL'],
      basic_auth: { username: session["access_token"], password: nil }
    )

    redirect to('/')
  end
end
