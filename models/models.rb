require 'mongo_mapper'
require 'ostruct'

MongoMapper.connection = Mongo::Connection.new('staff.mongohq.com',10001, :pool_size => 5, :timeout => 5)
MongoMapper.database = 'turntable'
MongoMapper.database.authenticate('turntable','TurnTable')

class User
  include MongoMapper::Document
  set_collection_name 'users'
  timestamps!
    
  def votes
    votes = Vote.all(:user_id => self.id.to_s)
  end
  
  def upvotes
    votes = Vote.all(:dj_id => self.id.to_s, :value => "up")
  end
  
  def downvotes
    votes = Vote.all(:dj_id => self.id.to_s, :value => "down")    
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
end

# require 'pry'
# binding.pry