class Badword < ActiveRecord::Base
  set_table_name "blacklist"
  
  validates_presence_of :term
end
