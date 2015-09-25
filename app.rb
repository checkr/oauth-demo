require "sinatra"
require "tilt/erb"
require "dotenv"
Dotenv.load

class DemoApp < Sinatra::Base
  enable :sessions
  CHECKR_AUTHORIZE_URL    = "http://dashboard.checkr.com/oauth/authorize/" \
                            "#{ENV["CHECKR_CLIENT_ID"]}" \
                            "?redirect_uri=#{ENV["REDIRECT_URI"]}"
  CHECKR_API              = "https://api.checkr.com"
  CHECKR_DEAUTHORIZE_URL  = "/oauth/deauthorize"
  CHECKR_TOKENS_URL       = "/oauth/tokens"
  CHECKR_CANDIDATES_URL   = "/v1/candidates"
  CHECKR_WEBHOOKS_URL     = "/v1/webhooks"
  CHECKR_PACKAGES_URL     = "/v1/packages"
  CHECKR_REPORTS_URL      = "/v1/reports"

  def get_webhooks
    response = HTTParty.get(
      "#{CHECKR_API}#{CHECKR_WEBHOOKS_URL}?order=desc",
      basic_auth: { username: session[:access_token], password: nil }
    )
    webhooks = JSON.parse(response.body)["data"]
  end

  def get_packages
    response = HTTParty.get(
      "#{CHECKR_API}#{CHECKR_PACKAGES_URL}?order=desc",
      basic_auth: { username: session[:access_token], password: nil }
    )
    packages = JSON.parse(response.body)["data"]
  end

  def get_candidates
    response = HTTParty.get(
      "#{CHECKR_API}#{CHECKR_CANDIDATES_URL}?order=desc",
      basic_auth: { username: session[:access_token], password: nil }
    )
    candidates = JSON.parse(response.body)["data"]
  end

  def get_index
    if session[:access_token] && !session[:access_token].nil?
      @token = session[:access_token]
      @headers = %w(id uri first_name last_name dob email report_ids)
      @candidates = get_candidates || []
      @webhooks = get_webhooks || []
      @package_headers = %w(id slug name apply_url screenings)
      @packages = get_packages || []
      @webhooks_headers = %w(id object_name type created_at data)
      @webhooks_received = session[:webhooks_received] || []
    end

    erb :index, layout: :layout
  end

  get "/" do
    get_index
  end

  get "/oauth_callback" do
    code = params[:code]

    response = HTTParty.post("#{CHECKR_API}#{CHECKR_TOKENS_URL}", body: {
      code: code,
      client_id: ENV["CHECKR_CLIENT_ID"],
      client_secret: ENV["CHECKR_CLIENT_SECRET"]
    })
    session[:access_token] = response["access_token"]
    get_index
  end

  get "/deauthorize" do
    HTTParty.post(
      "#{CHECKR_API}#{CHECKR_DEAUTHORIZE_URL}",
      basic_auth: { username: session["access_token"], password: nil }
    )
    session.delete("access_token")
    get_index
  end

  post "/webhooks" do
    response = HTTParty.post(
      "#{CHECKR_API}#{CHECKR_WEBHOOKS_URL}",
      body: { webhook_url: params["url"], region: "us" },
      basic_auth: { username: session[:access_token], password: nil }
    )
    get_index
  end

  post "/packages" do
    response = HTTParty.post(
      "#{CHECKR_API}#{CHECKR_PACKAGES_URL}",
      body: {
        slug: params["slug"],
        name: params["name"],
        screenings: [{type: params["type"], subtype: params["subtype"]}]
      },
      basic_auth: { username: session[:access_token], password: nil }
    )
    get_index
  end

  post "/candidates" do
    response = HTTParty.post(
      "#{CHECKR_API}#{CHECKR_CANDIDATES_URL}",
      body: {
        first_name: params["first_name"],
        middle_name: params["middle_name"],
        last_name: params["last_name"],
        email: params["email"],
        phone: params["phone"],
        zipcode: params["zipcode"],
        dob: params["dob"],
        ssn: params["ssn"],
        driver_license_number: params["driver_license_number"],
        driver_license_state: params["driver_license_state"]
      },
      basic_auth: { username: session[:access_token], password: nil }
    )
    get_index
  end

  post "/reports" do
    response = HTTParty.post(
      "#{CHECKR_API}#{CHECKR_REPORTS_URL}",
      body: {
        package: params["package"],
        candidate_id: params["candidate_id"]
      },
      basic_auth: { username: session[:access_token], password: nil }
    )
    get_index
  end

  post '/checkr/webhooks' do
    session[:webhooks_received] ||= []
    session[:webhooks_received] << params
    get_index
  end
end
