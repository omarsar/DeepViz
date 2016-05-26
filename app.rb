require 'sinatra'
require 'json'
require 'haml'
require 'httparty'
require_relative './helpers/helper.rb'
require './config/environment'

# Visualization API
class DeepViz < Sinatra::Base
  helpers Helpers

  # decide the API URL
  def self.setapi(master, slave)
    default = master
    begin
      response = HTTP.post(default)
      if response.code == 200
        return master
      else
        return slave
      end
    rescue
      return slave
    end
  end

  API_URL = setapi(ENV['API_URL_1'],ENV['API_URL_2'])

  # home url
  get '/?' do
    @api_url = API_URL
    haml :index
  end

  # home for comparison dashbaord
  get '/compare' do
    begin
      @api_url = API_URL
      # information about queried user
      @sample1_data = getUserData(params['sample1radio'], params['username1'], @api_url)
      @sample2_data = getUserData(params['sample2radio'], params['username2'], @api_url)

      # separate the data into two pieces
      @sample1_profile = @sample1_data['profile']
      @sample1_report = @sample1_data['report']

      @sample2_profile = @sample2_data['profile']
      @sample2_report = @sample2_data['report']

      @sample1_tweets_polarity = getTweetsPolarityRatio(@sample1_report['positive_ratio'], @sample1_report['negative_ratio'])

      @sample2_tweets_polarity = getTweetsPolarityRatio(@sample2_report['positive_ratio'], @sample2_report['negative_ratio'])

      tweetParsing = Proc.new{ |tweet|
          {
            x: 0,
            polarity: tweet['polarity'],
            low: Time.parse(tweet['time']).to_i,
            high: Time.parse(tweet['time']).to_i + (tweet['dt'] * 60).to_i,
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
