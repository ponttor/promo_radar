require "playwright"

module CompetitorMonitoring
  class PlaywrightInstagramScraper
    USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    def fetch_posts(url:, session_json:)
      posts = []

      Playwright.create(playwright_cli_executable_path: playwright_cli) do |pw|
        pw.chromium.launch(headless: true) do |browser|
          context = browser.new_context(
            storageState: JSON.parse(session_json),
            userAgent: USER_AGENT
          )
          page = context.new_page
          page.goto(url, waitUntil: "networkidle")

          if page.url.include?("/accounts/")
            context.close
            raise CompetitorMonitoring::FetchInstagramPosts::SessionExpiredError
          end

          links = collect_post_links(page)
          posts = links.filter_map { |link| extract_post(page, link) }
          context.close
        end
      end

      posts
    end

    private

    def collect_post_links(page)
      seen = Set.new
      prev = 0

      15.times do
        links = page.eval_on_selector_all(
          'a[href*="/p/"], a[href*="/reel/"]',
          'els => [...new Set(els.map(el => el.href))]'
        )
        seen.merge(links)
        break if seen.size == prev
        prev = seen.size
        page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
        page.wait_for_timeout(1500)
      end

      seen.to_a
    end

    def extract_post(page, permalink)
      page.goto(permalink, waitUntil: "domcontentloaded")

      og_desc  = page.get_attribute('meta[property="og:description"]', "content")
      og_image = page.get_attribute('meta[property="og:image"]', "content")
      time_str = page.get_attribute("time[datetime]", "datetime")

      shortcode = permalink.match(%r{/(p|reel)/([^/?]+)})&.captures&.last
      return nil unless shortcode

      {
        instagram_id:   shortcode,
        posted_at:      time_str ? Time.zone.parse(time_str) : nil,
        post_type:      permalink.include?("/reel/") ? "reel" : "photo",
        caption:        parse_caption(og_desc),
        likes_count:    parse_count(og_desc, "like"),
        comments_count: parse_count(og_desc, "comment"),
        media_url:      og_image,
        permalink:      permalink.split("?").first
      }
    rescue => e
      Rails.logger.warn "[Instagram] Failed to extract #{permalink}: #{e.message}"
      nil
    end

    def parse_caption(og_desc)
      return nil if og_desc.blank?
      og_desc.match(/:\s*"?(.+?)(?:"\s*\z|\z)/m)&.captures&.first&.strip
    end

    def parse_count(og_desc, word)
      og_desc&.match(/([\d,]+)\s+#{word}/)&.captures&.first&.gsub(",", "")&.to_i || 0
    end

    def playwright_cli
      Rails.root.join("node_modules/.bin/playwright").to_s
    end
  end
end
