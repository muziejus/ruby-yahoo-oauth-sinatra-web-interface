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
      "ENV['YAHOO_CLIENT_ID' is nil."
    else
      "The id is: #{settings.yahoo_client_id}"
    end
  end

end
