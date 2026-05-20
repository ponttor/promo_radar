module CompetitorMonitoring
  class GenerateReport
    def self.call(report_type:, date_range:, competitor_ids: nil)
      new(report_type, date_range, competitor_ids).call
    end

    def initialize(report_type, date_range, competitor_ids)
      @report_type = report_type
      @date_range = date_range
      @competitor_ids = competitor_ids
    end

    def call
      events = fetch_events
      grouped = events.group_by { |e| e.promotion.competitor }
      markdown = build_markdown(grouped)
      html = render_html(markdown)

      ActiveRecord::Base.transaction do
        report = Report.create!(
          report_type:      @report_type,
          scope_json:       build_scope_json,
          summary_markdown: markdown,
          summary_html:     html,
          generated_at:     Time.current
        )

        if events.any?
          items = events.each_with_index.map do |event, i|
            { report_id: report.id, promotion_event_id: event.id, sort_order: i,
              created_at: Time.current, updated_at: Time.current }
          end
          ReportItem.insert_all!(items)
        end

        report
      end
    end

    private

    def fetch_events
      scope = PromotionEvent
        .joins(:promotion)
        .includes(promotion: :competitor)
        .where(created_at: @date_range)

      scope = scope.where(promotions: { competitor_id: @competitor_ids }) if @competitor_ids.present?
      scope.order("promotions.competitor_id ASC, promotion_events.created_at ASC")
    end

    def build_scope_json
      {
        "competitor_ids" => @competitor_ids,
        "date_from"      => @date_range.begin.iso8601,
        "date_to"        => @date_range.end.iso8601
      }
    end

    def build_markdown(grouped)
      date_label = @date_range.end.strftime("%d.%m.%Y")
      lines = [ "# Správa za #{date_label}", "" ]

      grouped.each do |competitor, events|
        lines << "## #{competitor.name}"
        events.each { |e| lines << format_event_line(e) }
        lines << ""
      end

      lines.join("\n")
    end

    def format_event_line(event)
      title = event.promotion.canonical_title.presence || "(bez názvu)"

      case event.event_type
      when "created"
        "- 🆕 Nová akcia: **#{title}**"
      when "updated"
        changes = (event.details_json || {}).filter_map do |field, v|
          next unless v.is_a?(Hash)
          "#{field}: #{v['from']} → #{v['to']}"
        end.join(", ")
        suffix = changes.present? ? " — #{changes}" : ""
        "- ✏️ Aktualizovaná: **#{title}**#{suffix}"
      when "ended"
        "- 🔚 Ukončená: **#{title}**"
      when "reappeared"
        "- 🔄 Obnovená: **#{title}**"
      else
        "- #{title}"
      end
    end

    def render_html(markdown)
      renderer = Redcarpet::Render::HTML.new(safe_links_only: true, escape_html: true)
      Redcarpet::Markdown.new(renderer, autolink: true, tables: true).render(markdown)
    end
  end
end
