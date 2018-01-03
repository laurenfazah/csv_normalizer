require 'csv'
require 'pry'

class Normalizer
  attr_reader :csv_path, :data

  def initialize(csv_path)
    @csv_path = csv_path
    @data = []
  end

  def read_csv
    CSV.foreach(csv_path, headers: true, header_converters: :symbol).with_index do |row, index|
      data << row.to_h
    end
  end

  def write_csv
    CSV.open("./output/#{file_name}", "wb") do |csv|
      csv << data.first.keys
    end

    data.each do |row|
      CSV.open("./output/#{file_name}", "a+") do |csv|
        csv << row.values
      end
    end
  end

  def convert_time_iso(time)
    DateTime.parse(time).iso8601
  end

  private

  def file_name
    csv_path.split("/").last
  end
end
