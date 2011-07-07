require 'rubygems'
require 'open-uri'
require 'sinatra'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('staff.mongohq.com',10001, :pool_size => 5, :timeout => 5)
MongoMapper.database = 'turntable'
MongoMapper.database.authenticate('turntable','TurnTable')

class User
  include MongoMapper::Document
end

class Song
  include MongoMapper::Document
end

class Vote
  include MongoMapper::Document
  key :user_id, String
  key :song_id, String
  key :dj_id, String
end

set :public, File.dirname(__FILE__) + '/public'

get '/' do
  open(File.dirname(__FILE__) + '/public/index.html').read
end

get '/user' do
  user = User.new(params['user']).to_mongo 
  User.collection.update(user, user, :upsert => true)
  puts ""
  p params
  puts ""
end

get '/song' do
  song = Song.new(params['song']).to_mongo 
  Song.collection.update(song, song, :upsert => true)
  puts ""
  p params
  puts ""
end

get '/vote' do
  vote = Vote.new(params['vote']).to_mongo 
  Vote.collection.update(vote, vote, :upsert => true)
  puts ""
  p params
  puts ""
end

get '/b' do
  open(params[:url]).read
end

run Sinatra::Application