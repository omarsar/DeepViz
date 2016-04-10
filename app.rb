require 'sinatra'
require 'json'
require 'haml'

# Visualization API
class DeepViz < Sinatra::Base
  # home url
  get '/?' do    
    haml :index
  end

  # home for bpd users
  get '/bpd'
    
  end

  # home for bp users
  get '/bp'
  
  end

end