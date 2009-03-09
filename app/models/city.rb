class City < ActiveRecord::Base
  has_many :mentions
end
