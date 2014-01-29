require 'rest_client'
require 'json'

module Lolcommits
  class Groupme < Plugin
    attr_accessor :bot_token 
    attr_accessor :access_token

    IMAGE_SERVICE_URL = "https://image.groupme.com/images"
    BOT_URL = "https://api.groupme.com/v3/bots/post"

    def initialize(runner)
      super
      self.options << 'bot_token'
      self.options << 'access_token'
    end

    def run
      debug "in run"
      return unless valid_configuration?

      repo = self.runner.repo.to_s
      debug "repo: #{repo}"

      debug "config: bot_token=" + configuration["bot_token"]
      debug "config: access_token=" + configuration["access_token"]

      if not repo.empty?
        # upload image to image service
        response = RestClient.post(
          IMAGE_SERVICE_URL, 
          { :file => File.new(self.runner.main_image) },
          { "X-Access-Token" => configuration["access_token"] }
        )
        debug "#{response}"
        
        response = JSON.parse(response)
        image_url = response["payload"]["url"]
        debug "#{image_url}"

        body = {
            :bot_id => configuration["bot_token"],
            :text => self.runner.message,
            :attachments => [{ :type => "image", :url => image_url }]
          }.to_json
        debug body

        message_response = RestClient.post(
          BOT_URL, 
          body,
          {:content_type => :json, :accept => :json}
        )
        debug message_response
      end
    end

    def is_configured?
      configuration["bot_token"] && configuration["access_token"]
    end

    def self.name
      'groupme'
    end
  end
end
