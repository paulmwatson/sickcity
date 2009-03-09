ActionController::Routing::Routes.draw do |map|
  map.connect '/mentions/import_downloaded', :controller => 'mentions', :action => 'import_downloaded'
  map.connect '/mentions/download_urls', :controller => 'mentions', :action => 'download_urls'
  map.connect '/mentions/update_urls', :controller => 'mentions', :action => 'update_urls'
  map.connet '/about', :controller => 'site', :action => 'about'
  map.connect '/:country', :controller => 'cities'
  map.connect '/:country/:city', :controller => 'phrases'
  
  map.connect '/:country/:city/:phrase', :controller => 'mentions'
  map.connect '/:country/:city/:phrase/:date', :controller => 'mentions'
  map.connect '/:country/:city/:phrase/:date/update', :controller => 'mentions', :update => true

  map.root :controller => 'cities'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
