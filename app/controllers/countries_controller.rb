class CountriesController < ApplicationController
  layout 'base'
  def index
    @countries = Country.find :all, :order => 'name'
  end
end
