class CitiesController < ApplicationController
  layout 'base'
  def index
    @cities = City.find :all, :order => 'country, name'
  end
end
