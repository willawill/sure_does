require 'sinatra/base'
require 'net/http'
require 'json'

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
      JSON.parse(res.body)
    end
  end

  get '/ping' do
    "I am still up at #{Time.now}"
  end

  get '/export-new-post' do
    "#{fetch_posts}"
  end

  run! if app_file == $0
end