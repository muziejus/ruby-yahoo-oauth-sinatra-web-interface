# encoding: utf-8
require "sinatra/base"
require "json"
require "dotenv"
require "httparty"
require "haml"
require "yaml"

Dotenv.load

class App < Sinatra::Base
  
  # Get the Yahoo! variables
  set :yahoo_client_id, ENV['YAHOO_CLIENT_ID']
  set :yahoo_client_secret, ENV['YAHOO_CLIENT_SECRET']

  # Configure haml and erb
  set :haml, format: :html5
  set :erb, layout_engine: :haml, layout: :layout

  get "/" do
    erb :index
  end

  get "/authenticate" do
    if settings.yahoo_client_id.nil?
      erb :unconfigured
    else
      yahoo_url = "https://api.login.yahoo.com/oauth2/request_auth?" +
        "client_id=#{settings.yahoo_client_id}&" +
        "redirect_uri=oob&" + # Out of bounds
        "response_type=code&" +
        "language=en-us"
      erb :authenticate, locals: { 
        yahoo_url: yahoo_url
      }
    end
  end

  post "/get-token" do
    if params[:code].nil?
      "No code entered!"
    else
      response = HTTParty.post("https://api.login.yahoo.com/oauth2/get_token",
        {
          body: {
            "client_id" => settings.yahoo_client_id,
            "client_secret" => settings.yahoo_client_secret,
            "redirect_uri" => "oob",
            "code" => params[:code],
            "grant_type" => "authorization_code"
          }
        }
      )
      if response.parsed_response["error"].nil?
        if Sinatra::Base.development?
          File.open('yahoo.yml', 'w') do |file|
            file.puts YAML::dump(response.parsed_response)
          end
        else # dump to Heroku environment variables.
          ENV['ACCESS_TOKEN'] = response.parsed_response['access_token']
          ENV['REFRESH_TOKEN'] = response.parsed_response['refresh_token']
          ENV['XOAUTH_YAHOO_GUID'] = response.parsed_response['xoauth_yahoo_guid']
        end
        redirect '/test-api'
      else
        "There was an error! #{response.parsed_response["error_description"]}"
      end
    end
  end

  get '/test-api' do
    response = HTTParty.get "https://social.yahooapis.com/v1/user/#{xoauth_yahoo_guid}/profile?format=json",
      headers: { "Authorization" => "Bearer #{access_token}" }
    erb :test_api, locals: { profile: response.parsed_response["profile"] }
  end

  def access_token
    if File.exists? 'yahoo.yml'
      YAML::load_file('yahoo.yml')['access_token']
    elsif ENV['ACCESS_TOKEN']
      ENV['ACCESS_TOKEN']
    else
      raise "No access token found."
    end
  end

  def xoauth_yahoo_guid
    if File.exists? 'yahoo.yml'
      YAML::load_file('yahoo.yml')['xoauth_yahoo_guid']
    elsif ENV['XOAUTH_YAHOO_GUID']
      ENV['XOAUTH_YAHOO_GUID']
    else
      raise "No yahoo guid found."
    end
  end
end
