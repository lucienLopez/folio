# frozen_string_literal: true

class OrdersImporter < ApplicationService
  CSV_OPERATION_TYPES = {
    'Achat' => Order::BUY,
    'Vente' => Order::SELL
  }.freeze

  def initialize(file_path)
    @file_path = file_path
  end

  def call
    require 'csv'

    csv_data = File.readlines(@file_path, encoding: 'UTF-8')[4..] # Skip first 4 lines

    CSV.parse(csv_data.join, headers: true, col_sep: ';') do |row|
      operation_type = CSV_OPERATION_TYPES[row["Type d’opération"]]
      next unless operation_type
      next unless row['Statut'] == 'Exécuté'

      security = Security.find_or_create_by!(isin: row['Isin']) do |s|
        s.name = row['Nom']
      end

      order = Order.find_or_initialize_by(
        security: security,
        reference_number: row['Référence']
      )

      price = row["Cours d'exécution"].to_s.gsub(/[^\d.,]/, "").tr(",", ".").to_f
      currency = CurrencyParser.parse(row["Cours d'exécution"], row['Place'])
      executed_at = Date.parse(row['Date de création'])
      price_eur = CurrencyConverter.call(
        amount: price,
        from: currency,
        date: executed_at
      )

      order.update!(
        operation_type: operation_type,
        shares: row['Quantité'].to_i,
        price: price,
        currency: currency,
        price_eur: price_eur,
        total_amount: row['Montant'].to_s.gsub(/[^\d.,]/, '').tr(',', '.').to_f.abs,
        executed_at: executed_at
      )
    end
  end
end
