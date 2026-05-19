module CompetitorMonitoring
  class FetchInstagramPosts
    SessionExpiredError = Class.new(StandardError)

    def self.call(monitoring_source:, scraper: nil)
      new(monitoring_source, scraper || PlaywrightInstagramScraper.new).call
    end

    def initialize(source, scraper)
      @source = source
      @scraper = scraper
    end

    def call
      credential = InstagramCredential.find_by!(active: true)
      known_ids   = @source.instagram_posts.pluck(:instagram_id).to_set

      posts_data = @scraper.fetch_posts(url: @source.url, session_json: credential.session_json)

      created = posts_data.reject { |p| known_ids.include?(p[:instagram_id]) }.filter_map do |data|
        @source.instagram_posts.create!(
          instagram_id:   data[:instagram_id],
          posted_at:      data[:posted_at],
          post_type:      data[:post_type],
          caption:        data[:caption],
          hashtags:       extract_hashtags(data[:caption]),
          likes_count:    data[:likes_count].to_i,
          comments_count: data[:comments_count].to_i,
          media_url:      data[:media_url],
          permalink:      data[:permalink],
          fetched_at:     Time.current
        )
      rescue ActiveRecord::RecordNotUnique
        nil
      end

      credential.update_column(:last_verified_at, Time.current)
      created
    rescue SessionExpiredError
      InstagramCredential.update_all(active: false)
      raise
    end

    private

    def extract_hashtags(caption)
      return [] if caption.blank?
      caption.scan(/#(\w+)/).flatten
    end
  end
end
