require 'sinatra'
require 'json'
require 'haml'
require 'httparty'
#require './config/environment'
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

    # separate the data into two pieces
    @user_profile = @user_data['profile']
    @user_report = @user_data['report']

    # has to be in json format before feeding into word cloud
    @word_cloud_text = [{"text": "omar" ,"size":9}, {"text": "elvis" ,"size":5}]

    haml :bpd    
  end

  # home for bp users
  get '/bd' do
  
  end

end