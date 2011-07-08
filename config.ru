require 'rubygems'
require 'open-uri'
require 'sinatra'
require 'haml'
# require 'ap'

require File.dirname(__FILE__) + '/lib/rmend.rb'
require File.dirname(__FILE__) + '/models/models.rb'


set :public, File.dirname(__FILE__) + '/public'

get '/' do
  open(File.dirname(__FILE__) + '/public/index.html').read
end

get '/users' do
  @users = User.all
  haml :users
end

get '/users/plot' do
  @locs = {}
  locs = User.cluster_locs
  # locs = {"4defc3404fe7d0012e039149"=>[-2.057797075817216, 5.333442347569927], "4e134f49a3f75114d6040255"=>[4.943341030269761, 0.6577198718167823], "4e0cc340a3f7514674147b60"=>[0.585284240863284, 0.6231458140592313], "4e0cdc33a3f7514674168460"=>[-0.09506479984542994, 0.7065246061655807], "4ddc9bb9e8a6c4114e00010a"=>[-0.7077996949550848, 3.131278207375978], "4e0cdf7ca3f7514674170764"=>[0.46215946619765247, 0.7638860966661237], "4e1358aca3f75114d6044743"=>[0.8160523219348517, -1.9445792994733522], "4e0cc6f1a3f751467414cadc"=>[-0.309921722348506, 0.6417444627873852], "4dfecd38a3f75104e002488f"=>[0.16450912153157815, 0.8950121464352383], "4e0cc771a3f751467414cdab"=>[2.369708518580945, -0.6152823566921927], "4df107a44fe7d0631914cc6c"=>[0.46003426627434957, -1.5818863151363094], "4e138ccfa3f75114d6066e9a"=>[-0.24193478141811986, 0.6677729503437346], "4e0cc6cda3f751467414bd7c"=>[0.6825395037571336, 0.5872950734488944], "4e0e69d5a3f7516716015de1"=>[0.3708009683313055, 0.9802390856377362], "4df949364fe7d056bd07537c"=>[0.9328838892814133, -1.0822326429048816], "4e11fcafa3f75138c100d9e4"=>[0.33038947526220763, 0.929868976753894], "4df7afb74fe7d04a2007c576"=>[0.5333222368591034, 0.07355300805098941]}


  max_x, max_y, min_x, min_y = nil
  
  locs.each do |u_id, loc|
    x = loc[0]
    y = loc[1]
    
    max_x ||= x
    max_y ||= y
    min_x ||= x
    min_y ||= y
    
    max_x = x if x > max_x
    max_y = y if y > max_y
    
    min_x = x if x < min_x
    min_y = y if y < min_y
  end
  
  norm_locs = {}
  locs.each do |u_id, loc|
    x = loc[0]
    y = loc[1]
    
    norm_x = (x - min_x)/(max_x - min_x)
    norm_y = (y - min_y)/(max_y - min_y)
    
    norm_locs[u_id] = [norm_x, norm_y]
  end

  norm_locs.each do |user_id, loc|
    @locs[user_id] = {:loc => loc, :user => User.find(user_id)}
  end

  @locs
  haml :user_plot
end

get '/users/:id' do
  @user = User.find(params[:id])
  haml :show_user
end

get '/user' do
  TT.add_object(User, params['user'])
  # if user = User.find(params['user']['_id'])
  #   user.update_attributes(params['user'])
  # else
  #   User.create(params['user'])
  # end
end

get '/song' do
  TT.add_object(Song, params['song'])
  # song = Song.new(params['song']).to_mongo 
  # Song.collection.update(song, song, :upsert => true)
end

get '/vote' do
  TT.add_object(Vote, params['vote'])
  # vote = Vote.new(params['vote']).to_mongo 
  # Vote.collection.update(vote, vote, :upsert => true)
end

get '/b' do
  open(params[:url]).read
end

run Sinatra::Application