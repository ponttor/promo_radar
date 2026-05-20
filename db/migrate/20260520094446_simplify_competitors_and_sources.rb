class SimplifyCompetitorsAndSources < ActiveRecord::Migration[7.2]
  def change
    remove_column :competitors, :industry, :string
    remove_column :competitors, :country, :string
    remove_column :competitors, :notes, :text

    remove_column :monitoring_sources, :name, :string
    remove_column :monitoring_sources, :fetch_strategy, :string
    remove_column :monitoring_sources, :extractor_type, :string
    remove_column :monitoring_sources, :check_frequency, :string
  end
end
