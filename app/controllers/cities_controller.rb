class CitiesController < ApplicationController
  layout 'base'
  def index
    @cities = City.find :all, :include => :country, :conditions => {'countries.name' => params[:country]}, :order => 'cities.name'
  end
end
