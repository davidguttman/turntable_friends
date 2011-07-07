require 'rubygems'
require 'open-uri'
require 'sinatra'
require 'mongo_mapper'

# MongoMapper.connection = Mongo::Connection.new('staff.mongohq.com',27062, :pool_size => 5, :timeout => 5)
# MongoMapper.database = 'turntable'
# MongoMapper.database.authenticate('dguttman','SomePW')

set :public, File.dirname(__FILE__) + '/public'

get '/' do
  open(File.dirname(__FILE__) + '/public/index.html').read
end

get '/user' do
  puts ""
  p params
  puts ""
end

get '/song' do
  puts ""
  p params
  puts ""
end

get '/vote' do
  puts ""
  p params
  puts ""
end

get '/b' do
  open(params[:url]).read
end

run Sinatra::Application