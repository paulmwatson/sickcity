class CitiesController < ApplicationController
  layout 'base'
  def index
    @cities = City.find :all, :include => :country, :order => 'countries.name' #:conditions => {'countries.name' => params[:country]}, :order => 'cities.name'
  end
end
