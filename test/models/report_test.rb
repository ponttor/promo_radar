require "test_helper"

class ReportTest < ActiveSupport::TestCase
  def build_report(attrs = {})
    Report.new({
      report_type: :daily,
      generated_at: Time.current,
      summary_markdown: "# Test"
    }.merge(attrs))
  end

  test "valid with required fields" do
    assert build_report.valid?
  end

  test "invalid without report_type" do
    assert_not build_report(report_type: nil).valid?
  end

  test "invalid without generated_at" do
    assert_not build_report(generated_at: nil).valid?
  end

  test "enum report_type has daily, weekly, manual" do
    %w[daily weekly manual].each do |t|
      assert_includes Report.report_types.keys, t
    end
  end

  test "has_many report_items" do
    report = Report.create!(report_type: :daily, generated_at: Time.current, summary_markdown: "x")
    assert_respond_to report, :report_items
  end

  test "has_many promotion_events through report_items" do
    assert_respond_to Report.new, :promotion_events
  end
end
