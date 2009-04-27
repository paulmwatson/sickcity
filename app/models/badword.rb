class Badword < ActiveRecord::Base
  set_table_name "blacklist"
  
  validates_presence_of :term
  validates_uniqueness_of :term

  before_save :dont_save_phrases

  def dont_save_phrases
    return false if Phrase.find_by_title(self.term) 
  end
end
