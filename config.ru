require 'rubygems'
require 'open-uri'
require 'sinatra'
require 'haml'

require File.dirname(__FILE__) + '/models/models.rb'

set :public, File.dirname(__FILE__) + '/public'

get '/' do
  open(File.dirname(__FILE__) + '/public/index.html').read
end

get '/users' do
  @users = User.all
  haml :users
end

get '/users/:id' do
  @user = User.find(params[:id])
  haml :show_user
end

get '/user' do
  user = User.new(params['user']).to_mongo 
  User.collection.update(user, user, :upsert => true)
end

get '/song' do
  song = Song.new(params['song']).to_mongo 
  Song.collection.update(song, song, :upsert => true)
end

get '/vote' do
  vote = Vote.new(params['vote']).to_mongo 
  Vote.collection.update(vote, vote, :upsert => true)
end

get '/b' do
  open(params[:url]).read
end

run Sinatra::Application