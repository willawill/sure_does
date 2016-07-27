require 'sinatra/base'
require 'net/http'
require 'json'
require 'csv'

class SureDoes < Sinatra::Base
  configure do
    set :base_uri, 'http://www.reddit.com/r/sleepparalysis'
  end

  helpers do
    def fetch_posts
      url = URI.parse(settings.base_uri + '/new.json')
      req = Net::HTTP::Get.new(url)
      req.add_field('User-Agent', 'Sure Does')
      res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
      JSON.parse(res.body)["data"]
    end

    def process_post(item)
      post = item["data"]

      [ post["title"],
        post["selftext"],
        post["author"],
        post["url"],
        Time.at(post['created'].to_i)]
    end

    def to_csv(data)
      CSV.generate do |csv|
        csv << ["Title", "Text", "Author", "Permlink", "Created_At"]

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
    posts = fetch_posts["children"]
    after = fetch_posts["after"]

    content_type 'application/csv'
    attachment   "data_#{after}.csv"

    to_csv(posts)
  end

  run! if app_file == $0
end