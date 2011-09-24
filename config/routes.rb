GeohashExplorer::Application.routes.draw do
  match ':id' => 'home#show'
  root :to => 'home#show'
end
