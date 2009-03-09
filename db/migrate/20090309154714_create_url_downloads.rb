class CreateUrlDownloads < ActiveRecord::Migration
  def self.up
    create_table :url_downloads do |t|
      t.column 'filename', :string
      t.column 'url', :string
      t.column 'downloaded', :boolean, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :url_downloads
  end
end
