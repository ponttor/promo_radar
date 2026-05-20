require "digest"

module CompetitorMonitoring
  class FetchSource
    USER_AGENT = "PromoRadar/1.0"

    def self.call(monitoring_source:)
      new(monitoring_source).call
    end

    def initialize(monitoring_source)
      @source = monitoring_source
    end

    def call
      response = http_get
      build_snapshot(response)
    rescue Faraday::TimeoutError, Net::OpenTimeout, Net::ReadTimeout, Faraday::ConnectionFailed => e
      timeout_msg = e.message.to_s.match?(/timeout|timed out|execution expired/i) ? "timeout" : e.message.to_s.truncate(255)
      @source.source_snapshots.create!(
        fetched_at: Time.current, status: :failed, error_message: timeout_msg
      )
    rescue => e
      @source.source_snapshots.create!(
        fetched_at: Time.current, status: :failed,
        error_message: e.message.to_s.truncate(255)
      )
    ensure
      @source.update_column(:last_checked_at, Time.current)
    end

    private

    def http_get
      conn = Faraday.new do |f|
        f.options.open_timeout = 10
        f.options.timeout      = 30
      end
      conn.get(@source.url) { |req| req.headers["User-Agent"] = USER_AGENT }
    end

    def build_snapshot(response)
      status = http_status_to_status(response.status)

      unless status == :success
        return @source.source_snapshots.create!(
          fetched_at: Time.current,
          status: status,
          http_status: response.status,
          error_message: "HTTP #{response.status}"
        )
      end

      doc = Nokogiri::HTML(response.body)
      doc.css("script, style").remove
      visible_text = doc.at("body")&.text&.gsub(/[[:space:]]+/, " ")&.strip
      title = doc.at("title")&.text&.strip
      metas = doc.css("meta").each_with_object({}) do |m, h|
        k = m["name"] || m["property"]
        h[k] = m["content"] if k && m["content"]
      end

      @source.source_snapshots.create!(
        fetched_at:   Time.current,
        status:       :success,
        http_status:  response.status,
        raw_html:     response.body,
        visible_text: visible_text,
        title:        title,
        meta_json:    metas,
        content_hash: Digest::SHA256.hexdigest(visible_text.to_s)
      )
    end

    def http_status_to_status(code)
      return :blocked if [ 403, 429 ].include?(code)
      return :failed  if code >= 400
      :success
    end
  end
end
