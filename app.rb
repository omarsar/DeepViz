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

    def getUserData(radio, username)
      begin
        if radio == "username"
          return HTTParty.get(API_URL + "predict_json_by_name?screen_name=#{username}")
        else
          if radio == "bd"
            res = HTTParty.get(API_URL + "predict_json_by_id?user_id=#{get_bipolar()}")
            res['profile']['name'] = "Bipolar Patient"
            res['profile']['screen_name'] = 'randomBipolarPatient'
          else
            res = HTTParty.get(API_URL + "predict_json_by_id?user_id=#{get_bpd()}")
            res['profile']['name'] = "BPD Patient"
            res['profile']['screen_name'] = 'randomBPDPatient'
          end
          res['profile']['profile_image_url'] = 'https://pixabay.com/static/uploads/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png'
          res['profile']['profile_banner_url'] = 'https://pbs.twimg.com/profile_banners/6253282/1431474710/1500x500'
          res['profile']['description'] = ''
        end
        res
      rescue => e
        logger.info "FAILED to get user information: #{e.inspect}"
        halt 404, "USER NOT FOUND: #{username}"
      end
    end


    # information about queried user
    @sample1_data = getUserData(params['sample1radio'], params['username1'])
    @sample2_data = getUserData(params['sample2radio'], params['username2'])

    # separate the data into two pieces
    @sample1_profile = @sample1_data['profile']
    @sample1_report = @sample1_data['report']

    @sample2_profile = @sample2_data['profile']
    @sample2_report = @sample2_data['report']

    def getTweetsPolarityRatio(positive_ratio, negative_ratio)
      [
        positive_ratio,
        1 - positive_ratio - negative_ratio,
        negative_ratio
      ]
    end

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
  end
end
