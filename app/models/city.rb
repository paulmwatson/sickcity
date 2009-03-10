class City < ActiveRecord::Base
  has_many :mentions
  has_many :histories
end
