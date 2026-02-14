class OrdersImporter < ApplicationService
  def initialize(file_path)
    @file_path = file_path
  end

  def call
    require 'csv'

    csv_data = File.readlines(@file_path, encoding: 'UTF-8')[4..] # Skip first 4 lines

    CSV.parse(csv_data.join, headers: true, col_sep: ';') do |row|
      next unless row['Type d’opération'] == 'Achat'
      next unless row['Statut'] == 'Exécuté'

      unless security = Security.find_by(isin: row['Isin'])
        security = Security.create!(
          isin: row['Isin'],
          name: row['Nom']
        )
      end

      investment = Investment.find_or_initialize_by(
        security: security,
        reference_number: row['Référence'],
      )
      investment.update!(
        shares: row['Quantité'].to_i,
        purchase_price: row['Cours d’exécution'].to_s.gsub(/[^\d.,]/, '').tr(',', '.').to_f,
        total_price: row['Montant'].to_s.gsub(/[^\d.,]/, '').tr(',', '.').to_f.abs,
        purchased_at: Date.parse(row['Date de création']),
      )
    end
  end
end