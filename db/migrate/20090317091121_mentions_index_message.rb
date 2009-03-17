class MentionsIndexMessage < ActiveRecord::Migration
  def self.up
    add_column :mentions, :message, :string
    add_column :mentions, :source_id, :integer
    add_index :mentions, :source_id
  end

  def self.down
  end
end
