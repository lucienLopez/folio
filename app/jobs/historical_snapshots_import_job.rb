# frozen_string_literal: true

class HistoricalSnapshotsImportJob < ApplicationJob
  queue_as :default

  def perform
    last_date = PortfolioSnapshot.global.maximum(:date)
    since = last_date ? last_date + 1.day : nil

    HistoricalSnapshotImporter.call(since: since)

    existing_portfolio_dates = PortfolioSnapshot.global.pluck(:date).to_set

    SecuritySnapshot
      .select("DATE(created_at) AS d")
      .distinct
      .pluck("DATE(created_at)")
      .map { |d| d.is_a?(Date) ? d : Date.parse(d.to_s) }
      .reject { |d| existing_portfolio_dates.include?(d) }
      .sort
      .each { |date| PortfolioSnapshotRecorder.call(date: date) }
  end
end
