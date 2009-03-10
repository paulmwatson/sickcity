class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.column 'city_id', :integer
      t.column 'phrase_id', :integer
      t.column 'last_get', :timestamp
      t.timestamps
    end
  end

  def self.down
    drop_table :histories
  end
end
