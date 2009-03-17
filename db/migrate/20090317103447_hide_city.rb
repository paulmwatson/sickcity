class HideCity < ActiveRecord::Migration
  def self.up
    add_column :cities, :hidden, :boolean, :default => false
  end

  def self.down
  end
end
