# Heroku needs this file for configuration.
#
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

environment ENV['RACK_ENV'] || 'development'

rackup "config.ru"

