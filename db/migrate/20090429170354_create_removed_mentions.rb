class CreateRemovedMentions < ActiveRecord::Migration
  def self.up
    create_table :removed_mentions do |t|
      t.column 'mentioned_at', :timestamp
      t.column 'link', :string
      t.column 'exact_location', :string
      t.column 'phrase_id', :integer
      t.column 'city_id', :integer
      t.column 'mentioner', :string
      t.timestamps
    end
    
    add_column :removed_mentions, :message, :string
    add_column :removed_mentions, :source_id, :integer
    add_index :removed_mentions, :source_id, {:unique => true}
  end

  def self.down
    drop_table :removed_mentions
  end
end
