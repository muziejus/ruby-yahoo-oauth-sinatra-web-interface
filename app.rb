# encoding: utf-8
require "sinatra/base"
require "json"
require "dotenv"
require "httparty"
require "haml"

Dotenv.load

class App < Sinatra::Base
  
  # Get the Yahoo! variables
  set :yahoo_client_id, ENV['YAHOO_CLIENT_ID']
  set :yahoo_client_secret, ENV['YAHOO_CLIENT_SECRET']

  # Configure haml and erb
  set :haml, format: :html5
  set :erb, layout_engine: :haml, layout: :layout

  get "/" do
    "welcome… contents of README... you want to go to #{request.host_with_port}/authenticate."
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
      response.body
    end
  end

end
