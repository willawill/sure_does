require 'sinatra/base'
require 'net/http'
require 'json'
require 'csv'
require 'nokogiri'
require 'pry'

class SureDoes < Sinatra::Base
  helpers do
    def fetch_posts
      base_uri = 'https://www.reddit.com/r/sleepparalysis/new'
      user_agent = 'sure does'
      doc = Nokogiri::HTML(open(base_uri, 'User-Agent' => user_agent))
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
        post[:url],
        Time.at(post[:created].to_i)]
    end

    def to_csv(data)
      CSV.generate do |csv|
        csv << ["Title", "Author", "Permalink", "Created_At"]

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