require 'sinatra'
require 'json'
require 'haml'
require 'httparty'
require_relative './helpers/helper.rb'
require './config/environment'

# Visualization API
class DeepViz < Sinatra::Base
  helpers Helpers


  #API_URL =

  # home url
  get '/?' do
    @api_url = setapi(ENV['API_URL_1'],ENV['API_URL_2'])
    haml :index
  end

  # home for comparison dashbaord
  get '/compare' do
    begin
      @api_url = setapi(ENV['API_URL_1'],ENV['API_URL_2'])
      # information about queried user
      @sample1_data = getUserData(params['sample1radio'], params['username1'], @api_url)
      @sample2_data = getUserData(params['sample2radio'], params['username2'], @api_url)

      # separate the data into two pieces
      # Information for Sample 1
      @sample1_profile = @sample1_data['profile']
      @sample1_report = @sample1_data['report']
      @sample1_timeline_bipolar = prepare_timeline_data(@sample1_data['timeline']['bipolar'])
      @sample1_timeline_bpd = prepare_timeline_data(@sample1_data['timeline']['bpd'])

      # Information for sample 2
      @sample2_profile = @sample2_data['profile']
      @sample2_report = @sample2_data['report']
      @sample2_timeline_bipolar = prepare_timeline_data(@sample2_data['timeline']['bipolar'])
      @sample2_timeline_bpd = prepare_timeline_data(@sample2_data['timeline']['bpd'])

      @sample1_tweets_polarity = getTweetsPolarityRatio(@sample1_report['positive_ratio'], @sample1_report['negative_ratio'])

      @sample2_tweets_polarity = getTweetsPolarityRatio(@sample2_report['positive_ratio'], @sample2_report['negative_ratio'])

      tweetParsing = Proc.new{ |tweet|
          {
            x: 0,
            polarity: tweet['polarity'],
            low: DateTime.parse(tweet['time']).to_time.to_i*1000,
            high: DateTime.parse(tweet['time']).to_time.to_i*1000 + (tweet['dt'] * 60000).to_i,
            text: tweet['text']
          }
        }

      sample1_latest_tweets = @sample1_report['latest_tweets'].map(&tweetParsing)

      @sample1_positive_tweets = (sample1_latest_tweets.select { |tweet| tweet[:polarity] == 1 }).to_json
      @sample1_negative_tweets = (sample1_latest_tweets.select { |tweet| tweet[:polarity] == -1 }).to_json
      @sample1_neutral_tweets = (sample1_latest_tweets.select { |tweet| tweet[:polarity] == 0 }).to_json

      sample2_latest_tweets = @sample2_report['latest_tweets'].map(&tweetParsing)

      @sample2_positive_tweets = (sample2_latest_tweets.select { |tweet| tweet[:polarity] == 1 }).to_json
      @sample2_negative_tweets = (sample2_latest_tweets.select { |tweet| tweet[:polarity] == -1 }).to_json
      @sample2_neutral_tweets = (sample2_latest_tweets.select { |tweet| tweet[:polarity] == 0 }).to_json

      @sample1_bpd_word_count = bpd_word_count(@sample1_data['BPD_words'])

      @sample2_bpd_word_count = bpd_word_count(@sample2_data['BPD_words'])
      haml :compare
    rescue
      haml :error
    end
  end
end
