require 'sinatra'
require 'json'
require 'haml'
require 'httparty'
require_relative './helpers/helper.rb'
#require './config/environment'

# Visualization API
class DeepViz < Sinatra::Base
  helpers Helpers
  
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

    # array for dimensions of depression
    @dep_dimensions = [
      @user_report['BPD_probability'],
      @user_report['bipolar_probability'],
      @user_report['negative_combos'],
      @user_report['positive_combos'],
      #@user_report['first_pronoun_ratio'],
      @user_report['flips_ratio'],
      @user_report['negative_ratio'],
      @user_report['positive_ratio'],
    ]

    @bpd_word_count = bpd_word_count(@user_data['BPD_words'])


    haml :bpd    
  end

  # home for bp users
  get '/bd' do
  
  end

end