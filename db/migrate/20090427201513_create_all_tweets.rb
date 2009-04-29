class CreateAllTweets < ActiveRecord::Migration
  def self.up
    create_table :all_tweets do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :all_tweets
  end
end
