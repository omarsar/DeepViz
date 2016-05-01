require 'sinatra'
require 'json'
require 'haml'
require 'httparty'
require_relative './helpers/helper.rb'
require './config/environment'

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
    @user_data = HTTParty.get(API_URL + "predict_json_by_name?screen_name=#{@user_name}")

    # separate the data into two pieces
    @user_profile = @user_data['profile']
    @user_report = @user_data['report']

    @tweets_polarity = [
      @user_report['positive_ratio'],
      1 - @user_report['negative_ratio'] - @user_report['positive_ratio'],
      @user_report['negative_ratio'],
    ]

    tweetParsing = Proc.new{ |tweet|
        {
          x: 0,
          low: Time.parse(tweet['time']).to_i,
          high: Time.parse(tweet['time']).to_i + (tweet['dt'].to_i * 100),
          text: tweet['text']
        }
      }

    @positive_tweets = @user_report['positive_tweets'].map(&tweetParsing).to_json
    @negative_tweets = @user_report['negative_tweets'].map(&tweetParsing).to_json

    @bpd_word_count = bpd_word_count(@user_data['BPD_words'])
    haml :user
  end

  # home for bpd users
  get '/bpd' do
    # information about queried user
    @random_patient_name = get_bpd()
    @user_data = HTTParty.get(API_URL + "predict_json_by_id?user_id=#{@random_patient_name}")

    # separate the data into two pieces
    @user_profile = @user_data['profile']
    @user_report = @user_data['report']

    @tweets_polarity = [
      @user_report['positive_ratio'],
      1 - @user_report['negative_ratio'] - @user_report['positive_ratio'],
      @user_report['negative_ratio'],
    ]

    tweetParsing = Proc.new{ |tweet|
        {
          x: 0,
          low: Time.parse(tweet['time']).to_i,
          high: Time.parse(tweet['time']).to_i + (tweet['dt'].to_i * 10),
          text: tweet['text']
        }
      }

    @positive_tweets = @user_report['positive_tweets'].map(&tweetParsing).to_json
    @negative_tweets = @user_report['negative_tweets'].map(&tweetParsing).to_json

    @bpd_word_count = bpd_word_count(@user_data['BPD_words'])

    haml :patient
  end

  # home for bp users
  get '/bd' do
    # information about queried user
    @random_patient_name = get_bipolar()
    @user_data = HTTParty.get(API_URL + "predict_json_by_id?user_id=#{@random_patient_name}")

    # separate the data into two pieces
    @user_profile = @user_data['profile']
    @user_report = @user_data['report']

    @tweets_polarity = [
      @user_report['positive_ratio'],
      1 - @user_report['negative_ratio'] - @user_report['positive_ratio'],
      @user_report['negative_ratio'],
    ]

    tweetParsing = Proc.new{ |tweet|
        {
          x: 0,
          low: Time.parse(tweet['time']).to_i,
          high: Time.parse(tweet['time']).to_i + (tweet['dt'].to_i * 10),
          text: tweet['text']
        }
      }

    @positive_tweets = @user_report['positive_tweets'].map(&tweetParsing).to_json
    @negative_tweets = @user_report['negative_tweets'].map(&tweetParsing).to_json

    @bpd_word_count = bpd_word_count(@user_data['BPD_words'])

    haml :patient
  end

end
