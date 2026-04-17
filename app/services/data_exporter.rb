class DataExporter
  require 'csv'

  # Export a collection to CSV
  # @param collection [ActiveRecord::Relation]
  # @param columns [Array<Symbol, String>]
  # @return [String] CSV data
  def self.to_csv(collection, columns)
    CSV.generate(headers: true) do |csv|
      csv << columns.map(&:to_s).map(&:humanize)

      collection.find_each do |item|
        csv << columns.map { |col| item.send(col) }
      end
    end
  end

  # Export a collection to Excel (xlsx)
  # @param collection [ActiveRecord::Relation]
  # @param columns [Array<Symbol, String>]
  # @param sheet_name [String]
  # @return [String] Binary xlsx data
  def self.to_xlsx(collection, columns, sheet_name: 'Sheet1')
    p = Axlsx::Package.new
    p.workbook.add_worksheet(name: sheet_name) do |sheet|
      sheet.add_row columns.map(&:to_s).map(&:humanize)

      collection.find_each do |item|
        sheet.add_row columns.map { |col| item.send(col) }
      end
    end
    p.to_stream.read
  end
end
