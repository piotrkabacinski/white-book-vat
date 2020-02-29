require 'json'
require 'net/http'

# Bundler.require sets up the load paths and automatically requires every dependency,
# saving you from having to manually require each one.
require "bundler"
Bundler.setup(:default)

FACT = JSON.parse Net::HTTP.get('cat-fact.herokuapp.com', '/facts/5c72d9b651021f001415f00c')
puts FACT['text']