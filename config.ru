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
  add_object(User, params['user'])
  # if user = User.find(params['user']['_id'])
  #   user.update_attributes(params['user'])
  # else
  #   User.create(params['user'])
  # end
end

get '/song' do
  add_object(Song, params['song'])
  # song = Song.new(params['song']).to_mongo 
  # Song.collection.update(song, song, :upsert => true)
end

get '/vote' do
  add_object(Vote, params['vote'])
  # vote = Vote.new(params['vote']).to_mongo 
  # Vote.collection.update(vote, vote, :upsert => true)
end

get '/b' do
  open(params[:url]).read
end

def add_object(object_class, object)
  if persisted = object_class.find(object['_id'])
    persisted.update_attributes(object)
  else
    object_class.create(object)
  end
end

run Sinatra::Application