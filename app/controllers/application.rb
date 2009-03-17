# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :random_photo
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '305bf7bf7fce1e936651b4dcf92a011e'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  # Sets up @photo to be used in base.html.erb to show a random photo
  # for the selected city (or if no city is selected then just a random one)
  def random_photo
    if params[:city] && !params[:city][:name]
      city = City.find :first, :conditions => {:name => params[:city]}
      @photo = Photo.find :first, :conditions => {:city_id => city.id}
    end
    if !@photo
      @photo = Photo.find(:first, :offset => rand(Photo.all.size))
    end
    @photo['filename'] = "#{@photo.city.name.gsub(' ','').downcase}.jpg"
  end
end
