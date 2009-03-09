ActionController::Routing::Routes.draw do |map|
  map.connet '/about', :controller => 'site', :action => 'about'
  map.connect '/:country', :controller => 'cities'
  map.connect '/:country/:city', :controller => 'phrases'
  
  map.connect '/:country/:city/:phrase', :controller => 'tweets'
  map.connect '/:country/:city/:phrase/:date', :controller => 'tweets'

  map.root :controller => 'cities'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
