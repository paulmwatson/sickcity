class CreateMentions < ActiveRecord::Migration
  def self.up
    create_table :mentions do |t|
      t.column 'mentioned_at', :timestamp
      t.column 'link', :string
      t.column 'exact_location', :string
      t.column 'phrase_id', :integer
      t.column 'city_id', :integer
      t.column 'mentioner', :string
      t.timestamps
    end
  end

  def self.down
    drop_table :mentions
  end
end
