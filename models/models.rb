require 'mongo_mapper'
require 'ostruct'

MongoMapper.connection = Mongo::Connection.new('staff.mongohq.com',10001, :pool_size => 5, :timeout => 5)
MongoMapper.database = 'turntable'
MongoMapper.database.authenticate('turntable','TurnTable')

class TT
  def self.add_object(object_class, object)
    if persisted = object_class.find(object['_id'])
      persisted.update_attributes(object)
    else
      object_class.create(object)
    end
  end
end

class User
  include MongoMapper::Document
  set_collection_name 'users'
  timestamps!
  
  def self.similar_to(user)
    prefs = self.all_prefs
    r = Rmend.new
    matches = r.top_matches(prefs, user.id.to_s, prefs.size)
    matches.map {|rating| [rating[0], User.find(rating[1])]}
  end
  
  def self.all_prefs
    prefs = {}
    self.all.each do |user|
      prefs[user.id.to_s] = user.prefs
    end
    prefs
  end
    
  def votes
    votes = Vote.all(:user_id => self.id.to_s, :dj_id => {:$ne => self.id.to_s}).reverse
  end
  
  def plays
    plays = Vote.all(:user_id => self.id.to_s, :dj_id => self.id.to_s).map {|vote| vote.song.reverse
  end
  
  def upvotes
    votes = Vote.all(:dj_id => self.id.to_s, :value => "up", :user_id => {:$ne => self.id.to_s}).reverse
  end
  
  def downvotes
    votes = Vote.all(:dj_id => self.id.to_s, :value => "down").reverse    
  end
  
  def prefs
    prefs = {}
    self.votes.each do |vote|
      prefs[vote.song_id] = vote.value == "up" ? 1 : -1
    end
    prefs
  end
end

class Song
  include MongoMapper::Document
  set_collection_name 'songs'
  timestamps!
    
  def meta
    OpenStruct.new(self.metadata)
  end
end

class Vote
  include MongoMapper::Document
  set_collection_name 'votes'
  
  key :user_id, String
  key :song_id, String
  key :dj_id, String
  timestamps!
  
  def user
    User.find(self.user_id)
  end
  
  def dj
    User.find(self.dj_id)
  end
  
  def song
    Song.find(self.song_id)
  end
  
  def to_pref
    self.song_id + ':' + self.value
  end
end

# require File.dirname(__FILE__) + '/lib/rmend.rb'
# require 'pry'
# binding.pry