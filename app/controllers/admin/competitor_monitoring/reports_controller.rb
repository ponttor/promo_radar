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
        items = report.report_items.ordered
          .includes(promotion_event: { promotion: :competitor })
          .map do |item|
            event = item.promotion_event
            {
              id:               item.id,
              event_type:       event.event_type,
              promotion_id:     event.promotion_id,
              promotion_title:  event.promotion.canonical_title,
              competitor_name:  event.promotion.competitor.name,
              created_at:       event.created_at
            }
          end

        render inertia: "CompetitorMonitoring/Reports/Show", props: {
          report: {
            id:           report.id,
            report_type:  report.report_type,
            generated_at: report.generated_at,
            summary_html: report.summary_html,
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
    end
  end
end
