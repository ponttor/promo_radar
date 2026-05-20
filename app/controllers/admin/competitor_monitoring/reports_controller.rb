# frozen_string_literal: true

module Admin
  module CompetitorMonitoring
    class ReportsController < ApplicationController
      def index
        reports = Report.includes(:report_items).order(generated_at: :desc).map do |r|
          {
            id:           r.id,
            report_type:  r.report_type,
            generated_at: r.generated_at,
            events_count: r.report_items.size
          }
        end
        render inertia: "CompetitorMonitoring/Reports/Index", props: { reports: reports }
      end

      def show
        report = Report.find(params[:id])
        items  = build_items(report)

        render inertia: "CompetitorMonitoring/Reports/Show", props: {
          report: {
            id:           report.id,
            report_type:  report.report_type,
            generated_at: report.generated_at,
            summary_html: report.summary_html,
            ai_summary:   report.scope_json&.dig("ai_summary"),
            events_count: items.size,
            items:        items
          }
        }
      end

      def create
        from = Time.parse(params[:from].to_s).beginning_of_day
        to   = Time.parse(params[:to].to_s).end_of_day
        report = ::CompetitorMonitoring::GenerateReport.call(
          report_type: :manual,
          date_range:  from..to
        )
        redirect_to admin_competitor_monitoring_report_path(report)
      rescue ArgumentError, TypeError
        redirect_to admin_competitor_monitoring_reports_path,
          alert: "Invalid date range"
      end

      def regenerate_summary
        report = Report.find(params[:id])
        events = report.promotion_events.includes(promotion: :competitor).to_a

        if events.empty?
          return redirect_to admin_competitor_monitoring_report_path(report),
            alert: "No events to summarise"
        end

        input = events.map do |e|
          "#{e.event_type.upcase}: #{e.promotion.canonical_title} (#{e.promotion.competitor.name})"
        end.join("\n")

        result     = ::CompetitorMonitoring::ReportSummaryAgent.call(input: input)
        ai_summary = result.output.presence

        Rails.logger.debug "[AI] #{result.provider}/#{result.model} | input=#{input.length}chars | tokens=#{result.usage&.dig(:total_tokens)}"

        structural_md = extract_structural_markdown(report.summary_markdown)
        full_markdown  = ai_summary.present? ? "## AI Summary\n\n#{ai_summary}\n\n#{structural_md}" : structural_md

        report.update!(
          summary_markdown: full_markdown,
          scope_json:       report.scope_json.merge("ai_summary" => ai_summary)
        )

        redirect_to admin_competitor_monitoring_report_path(report)
      rescue ActiveHarness::Errors::AllModelsFailed => e
        Rails.logger.warn "ReportSummaryAgent failed for report #{report.id}: #{e.message}"
        redirect_to admin_competitor_monitoring_report_path(report),
          alert: "AI summary failed — please try again"
      end

      private

      def build_items(report)
        report.report_items.ordered
          .includes(promotion_event: { promotion: :competitor })
          .map do |item|
            event = item.promotion_event
            {
              id:              item.id,
              event_type:      event.event_type,
              promotion_id:    event.promotion_id,
              promotion_title: event.promotion.canonical_title,
              competitor_name: event.promotion.competitor.name,
              created_at:      event.created_at
            }
          end
      end

      def extract_structural_markdown(markdown)
        return markdown.to_s unless markdown.to_s.start_with?("## AI Summary\n")
        idx = markdown.index(/\n# /)
        idx ? markdown[(idx + 1)..] : markdown
      end
    end
  end
end
