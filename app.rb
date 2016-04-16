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

  # home for comparison dashbaord
  get '/compare' do
    # information about queried user

    @user_name = params['username']
    @user_data = HTTParty.get(API_URL + "predict_json?screen_name=#{@user_name}")

    # separate the data into two pieces
    @user_profile = @user_data['profile']
    @user_report = @user_data['report']

    # array for dimensions of depression
    @dep_dimensions = [
      @user_report['BPD_probability'],
      @user_report['bipolar_probability'],
      #@user_report['negative_combos'],
      #@user_report['positive_combos'],
      #@user_report['first_pronoun_ratio'],
      @user_report['mentioning_frequency'],
      @user_report['tweeting_frequency'],
      #@user_report['flips_ratio'],
      @user_report['negative_ratio'],
      @user_report['positive_ratio'],
    ]

    @bpd_word_count = bpd_word_count(@user_data['BPD_words'])
    # ==============================================================================
    # information about MD patient
    # TODO: obtain this from a database
    @random_patient_name = "BarelyNerdy"
    @random_patient_data = HTTParty.get(API_URL + "predict_json?screen_name=#{@random_patient_name}")

    # separate the data into two pieces
    @random_patient_profile = @random_patient_data['profile']
    @random_patient_report = @random_patient_data['report']

    @random_patient_dep_dimensions = [
      @random_patient_report['BPD_probability'],
      @random_patient_report['bipolar_probability'],
      #@random_patient_report['negative_combos'],
      #@random_patient_report['positive_combos'],
      #@user_report['first_pronoun_ratio'],
      @random_patient_report['mentioning_frequency'],
      @random_patient_report['tweeting_frequency'],
      #@random_patient_report['flips_ratio'],
      @random_patient_report['negative_ratio'],
      @random_patient_report['positive_ratio'],
    ]

    @random_patient_bpd_word_count = bpd_word_count(@random_patient_data['BPD_words'])

    @overlap_information = overlap_words(@user_data['BPD_words'], @random_patient_data['BPD_words'])

    @overlap_words = @overlap_information[0]
    @overlap_normal_count = @overlap_information[1]
    @overlap_patient_count = @overlap_information[2]

    haml :compare
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