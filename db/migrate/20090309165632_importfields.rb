class Importfields < ActiveRecord::Migration
  def self.up
    add_column :url_downloads, 'city_id', :integer
    add_column :url_downloads, 'phrase_id', :integer
    add_column :url_downloads, 'sample_date', :timestamp
    add_column :url_downloads, 'imported', :boolean, :default => false
  end

  def self.down
  end
end
