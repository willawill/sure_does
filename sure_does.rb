require 'sinatra/base'
require 'net/http'
require 'json'
require 'csv'
require 'nokogiri'
require 'pry'
require 'mechanize'

class SureDoes < Sinatra::Base
  configure do
    set :user_agent, 'sure does'
    set :base_uri, 'https://www.reddit.com/r/sleepparalysis/new'
  end

  helpers do
    def fetch_posts
      doc = Nokogiri::HTML(open(settings.base_uri, 'User-Agent' => settings.user_agent))
      docs = doc.css('.thing')
      docs.map do |post|
        {
          :title => post.css(".title").children().last.text,
          :author => post.attributes['data-author'].value,
          :url => "https://www.reddit.com" + post.attributes['data-url'].value,
          :created => post.attributes['data-timestamp'].value.to_s[0...-3]
        }
      end

    end

    def process_post(post)
      [ post[:title],
        post[:author],
        text,
        post[:url],
        Time.at(post[:created].to_i)]
    end

    def to_csv(data)
      CSV.generate do |csv|
        csv << ["Title", "Author", "SelfText", "Permalink", "Created_At"]

        data.each do |item|
          csv << process_post(item)
        end
      end
    end
  end

  get '/' do
    slim :index
  end

  get '/ping' do
    "I am still up at #{Time.now} PONG"
  end

  get '/export-new-post' do
    posts = fetch_posts
    content_type 'application/csv'
    attachment   "data.csv"

    to_csv(posts)
  end

  run! if app_file == $0
end