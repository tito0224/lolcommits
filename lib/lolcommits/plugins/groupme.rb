require 'rest_client'

module Lolcommits
  class Groupme < Plugin
    attr_accessor :groupme_bot_token 
    attr_accessor :groupme_access_token

    IMAGE_SERVICE_URL = "https://image.groupme.com/images"
    BOT_URL = "https://api.groupme.com/v3/bots/post"

    def initialize(runner)
      super
      self.options << 'groupme_bot_token'
      self.options << 'groupme_access_token'
    end

    def run
      return unless valid_configuration?

      repo = self.runner.repo.to_s
      if not repo.empty?
        # upload image to image service
        response = RestClient.post(
          IMAGE_SERVICE_URL, 
          { :file => File.new(self.runner.main_image) },
          { "X-Access-Toke" => configuration["groupme_access_token"] }
        )

        image_url = response.payload.url

        RestClient.post(
          BOT_URL, 
          {
            :bot_id => configuration["groupme_bot_token"],
            :text => self.runner.message,
            :attachments => { :type => "image", :url => image_url }
          }
        )
      end
    end

    def is_configured?
      !configuration["enabled"].nil? && configuration["groupme_bot_token"] 
        && configuration["groupme_access_token"]
    end

    def self.name
      'groupme'
    end
  end
end
