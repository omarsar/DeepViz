require 'sinatra'
require 'json'
require 'haml'
require 'httparty'
require './config/environment'
require 'bootstrap'

# Visualization API
class DeepViz < Sinatra::Base
  
  API_URL = ENV['API_URL']

  # home url
  get '/?' do
    @api_url = API_URL     
    haml :index
  end

  # home for bpd users
  get '/bpd' do
    @user_name = params['username']
    @user_data = HTTParty.get(API_URL + "predict_json?screen_name=#{@user_name}")
    haml :bpd    
  end

  # home for bp users
  get '/bp' do
  
  end

end