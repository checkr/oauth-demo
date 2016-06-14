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
        "#{ENV['CHECKR_API']}#{ENV['CHECKR_CANDIDATES_URL']}?test=true",
        basic_auth: { username: session["access_token"], password: nil }
      )['data']
    end

    erb :index, layout: :layout
  end

  get '/new_candidate' do
    response = HTTParty.post(ENV['CHECKR_API'] + '/v1/candidates',
      basic_auth: { username: session["access_token"], password: nil },
      body: {
        first_name:             'Your',
        middle_name:            'Full',
        last_name:              'Name',
        email:                  'your.name@example.com',
        phone:                  '5555555555',
        zipcode:                '90401',
        dob:                    '1970-01-22',
        ssn:                    '111-11-2001',
        driver_license_number:  'F1112001',
        driver_license_state:   'CA'
      }
    )
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
