class History < ActiveRecord::Base
  belongs_to :city
  belongs_to :phrase
end
