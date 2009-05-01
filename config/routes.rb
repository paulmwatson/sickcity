ActionController::Routing::Routes.draw do |map|
  map.resources :badwords
  
  map.connect '/removed_list/', :controller => 'mentions', :action => 'removed_list'
  map.connect '/mention/remove/:mention_id', :controller => 'mentions', :action => 'remove'
  map.connect '/mention/unremove/:mention_id', :controller => 'mentions', :action => 'unremove'
  
  map.connect '/cities/check/', :controller => 'cities', :action => 'check'
  map.connect '/cities/create/', :controller => 'cities', :action => 'create'
  map.connect '/cities/add/', :controller => 'cities', :action => 'new'
  map.connect '/mentions/import_60_days', :controller => 'mentions', :action => 'import_60_days'
  map.connet '/about', :controller => 'site', :action => 'about'
  map.connect '/:country', :controller => 'cities'
  map.connect '/:country/:city', :controller => 'phrases'
  map.connect '/:country/:city/:date', :controller => 'phrases'
  
  map.connect '/:country/:city/phrase/:phrase', :controller => 'mentions'
  map.connect '/:country/:city/phrase/:phrase/:date', :controller => 'mentions'
  
  map.resources :cities

  map.root :controller => 'countries'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
