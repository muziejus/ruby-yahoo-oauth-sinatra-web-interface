# ruby-yahoo-oauth-sinatra-web-interface

## Introduction

Yahoo! could do a better job with documentation. The goal here is to create an
access token with which you can then access hidden aspects of the Yahoo! API,
such as their [fantasy sports
API](https://developer.yahoo.com/fantasysports/guide/#league-resource). As a
[sinatra](http://sinatrarb.com) app, this app gives the users a few webpages to
click through to make the necessary queries to Yahoo!’s oauth system, and then
it saves the access token (and other tokens) to a yaml file, so the information
remains persistent over time.

Hence, this app can be deployed to, for example, Heroku, and be used to power a
Slack bot that has access to your team’s fantasy league(s).

## The authentication process in brief

This app makes the initial assumption that you have [registered a Yahoo!
developer app](https://developer.yahoo.com/apps/create/), and that you set the
permissions correctly. The two long strings, the `Client ID` and `Client
Secret` are required to generate an access token.

1. A url is generated with [https://api.login.yahoo.com/oauth2/request_auth](https://api.login.yahoo.com/oauth2/request_auth) that includes the `Client ID` as a parameter.

2. This url takes the logged-in Yahoo! user to an authorization page, where they grant the app authorization to do things. A code is then also given, which the user copies or notes.

3. The user is then taken back to this app, where, having entered the code, a `POST` request is made to [https://api.login.yahoo.com/oauth2/get_token](https://api.login.yahoo.com/oauth2/get_token). 

4. The subsequent response, containing the access token, is saved for future use, and now queries can be made to the Yahoo! API using the header `Authorization: Bearer access_tokenssjkjs823n24`

The app does this by running the route `/test-api`, which should show the user’s profile.

## Installation

1. Clone the repo.

2. `bundle install` to install the gems.

3. `cp .env.example .env` to create the `.env` file that holds the Yahoo! `client_id` and `client_secret` variables, which you have to add manually.

4. `cp puma.example.rb puma.rb`

5. `pumactl -F puma.rb start`

6. Point your browser to `http://localhost:9393/` and party.

7. Stop the webserver with `pumactl stop`.

## Todo

This is more a proof of concept than anything else, and I plan on forking this to write a Slack bot that access my fantasy baseball league, but there is one todo, for now:

* Add a means by which a token is refreshed if the access token has expired.

## Heroku installation

This works out of the box on Heroku, but you have to set the config vars with your Yahoo! `client_id` and `client_secret`. Because the access token is stored in a file that isn’t in git (`yahoo.yml`), every time you redeploy the app, you have to get a new access token. This is clumsy, but is also part of why deploying it on Heroku isn’t a brilliant idea.
