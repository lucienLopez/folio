# frozen_string_literal: true

namespace :portfolio_snapshots do
  desc "Backfill portfolio snapshots from existing SecuritySnapshot history"
  task backfill: :environment do
    dates = SecuritySnapshot
            .select("DATE(created_at) AS d")
            .distinct
            .pluck("DATE(created_at)")
            .sort

    if dates.empty?
      puts "No SecuritySnapshot records found — nothing to backfill."
      next
    end

    puts "Backfilling #{dates.size} date(s): #{dates.first} → #{dates.last}"

    dates.each do |date|
      PortfolioSnapshotRecorder.call(date: date.is_a?(Date) ? date : Date.parse(date.to_s))
      print "."
    end

    puts "\nDone. #{PortfolioSnapshot.count} portfolio snapshots total."
  end

  desc "Import historical prices from Yahoo Finance, then backfill portfolio snapshots"
  task import_history: :environment do
    HistoricalSnapshotImporter.call
    puts "\nBackfilling portfolio snapshots from imported history..."
    Rake::Task["portfolio_snapshots:backfill"].invoke
  end
end
