# frozen_string_literal: true

module CompetitorMonitoring
  class GenerateReport
    def self.call(report_type:, date_range:, competitor_ids: nil)
      new(report_type, date_range, competitor_ids).call
    end

    def initialize(report_type, date_range, competitor_ids)
      @report_type    = report_type
      @date_range     = date_range
      @competitor_ids = competitor_ids
    end

    def call
      events  = fetch_events
      grouped = events.group_by { |e| e.promotion.competitor }

      ai_summary, ai_calls = generate_ai_summary(events)
      ai_summary_skipped   = events.any? && ai_summary.nil?

      structural_markdown = build_markdown(grouped)
      full_markdown = if ai_summary.present?
        "## AI Summary\n\n#{ai_summary}\n\n#{structural_markdown}"
      else
        structural_markdown
      end
      html = render_html(structural_markdown)

      ActiveRecord::Base.transaction do
        report = Report.create!(
          report_type:      @report_type,
          scope_json:       build_scope_json(ai_summary:, ai_summary_skipped:, ai_calls_count: ai_calls),
          summary_markdown: full_markdown,
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

    def generate_ai_summary(events)
      return [ nil, 0 ] if events.empty?

      input = events.map do |e|
        "#{e.event_type.upcase}: #{e.promotion.canonical_title} (#{e.promotion.competitor.name})"
      end.join("\n")

      result = ReportSummaryAgent.call(input: input)
      Rails.logger.debug "[AI] #{result.provider}/#{result.model} | input=#{input.length}chars | tokens=#{result.usage&.dig(:total_tokens)}"
      [ result.output.presence, 1 ]
    rescue ActiveHarness::Errors::AllModelsFailed => e
      Rails.logger.warn "ReportSummaryAgent failed: #{e.message}"
      [ nil, 1 ]
    end

    def fetch_events
      scope = PromotionEvent
        .joins(:promotion)
        .includes(promotion: :competitor)
        .where(created_at: @date_range)

      scope = scope.where(promotions: { competitor_id: @competitor_ids }) if @competitor_ids.present?
      scope.order("promotions.competitor_id ASC, promotion_events.created_at ASC")
    end

    def build_scope_json(ai_summary:, ai_summary_skipped:, ai_calls_count:)
      hash = {
        "competitor_ids"  => @competitor_ids,
        "date_from"       => @date_range.begin.iso8601,
        "date_to"         => @date_range.end.iso8601,
        "ai_calls_count"  => ai_calls_count
      }
      hash["ai_summary"]         = ai_summary if ai_summary.present?
      hash["ai_summary_skipped"] = true if ai_summary_skipped
      hash
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
