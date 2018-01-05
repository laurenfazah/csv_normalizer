require './lib/normalizer'

RSpec.describe Normalizer do
  let(:working_sample_csv_path) { "./data/sample.csv" }
  let(:broken_sample_csv_path) { "./data/sample-with-broken-utf8.csv" }
  let(:normalizer) { described_class.new(working_sample_csv_path) }

  before(:each) do
    File.delete("./output/sample.csv") unless Dir.empty?('./output')
  end

  context "setup" do
    it "exists" do
      expect(normalizer).to be_truthy
      expect(normalizer).to be_a Normalizer
    end

    it "has readable CSV file path" do
      expect(normalizer.csv_path).to eq working_sample_csv_path
    end

    it "has readable data object" do
      expect(normalizer.data).to be_an Array
    end
  end

  context "read and write CSV" do
    it "can read and save CSV data" do
      expect(normalizer.data).to be_empty

      normalizer.read_csv

      expect(normalizer.data).not_to be_empty
      expect(normalizer.data).to be_an Array
    end

    it "can write CSV from read data" do
      expect(normalizer.data).to be_empty
      expect(Dir.empty?('./output')).to be_truthy

      normalizer.read_csv

      expect(normalizer.data).not_to be_empty

      normalizer.write_csv

      expect(Dir.empty?('./output')).to be_falsey
    end
  end

  context "normalizing" do
    it "converts timestamps column to ISO-8601 format" do
      unformatted_time = "4/1/11 11:00:00 AM"
      iso_formatted_time = "2004-01-11T11:00:00+00:00"

      expect(normalizer.convert_time_iso(unformatted_time)).to eq(iso_formatted_time)
    end

    it "converts timestamps column from Pacific to US/Eastern" do
      pacific = "2004-01-11T23:00:00+00:00"
      eastern = "2004-01-12T01:00:00+00:00"

      expect(normalizer.convert_pacific_to_eastern(pacific)).to eq(eastern)
    end

    it "ensures zip codes are 5 digits long" do
      valid_zip = "31403"
      invalid_zip = "1111"

      expect(normalizer.validate_zip(valid_zip)).to eq(valid_zip)
      expect(normalizer.validate_zip(invalid_zip)).to eq("01111")
    end

    it "converts all names to capitalized text" do
      names = %w(dwight Jim pAm anGelA)

      names.each do |name|
        expect(normalizer.capitalize_name(name)).to eq(name.upcase)
      end
    end

    it "recalculates the TotalDuration column values" do
      foo_duration = "1:29:32.123"
      bar_duration = "1:32:33.123"
      total = "3:02:05.246"

      rounded_total = normalizer.total_duration(foo_duration, bar_duration)

      expect(rounded_total).to eq(total)
    end
  end

  context "integration" do
    it "runs all validations when initialized with csv path" do
      expect(Dir.empty?('./output')).to be_truthy

      normalizer.run

      expect(Dir.empty?('./output')).to be_falsey

      read_csv = csv_read("./output/sample.csv")
      csv_headers = read_csv[0]
      csv_first_row = read_csv[1]
      csv_last_row = read_csv.last

      expect(csv_headers).to eq(expected_csv_data[:headers])

      # iso8601 and US/Eastern
      expect(csv_first_row[0]).to eq("2004-01-11T13:00:00+00:00")
      expect(csv_last_row[0]).to eq("2010-02-04T10:44:11+00:00")

      # 5 digit zip
      expect(csv_first_row[2]).to eq("94121")
      expect(csv_last_row[2]).to eq("00011")

      # name capitalized
      expect(csv_first_row[3]).to eq("MONKEY ALBERTO")
      expect(csv_last_row[3]).to eq("HERE WE GO")

      # totalduration recalculated
      expect(csv_first_row[6]).to eq(normalizer.total_duration(csv_first_row[4], csv_first_row[5]))
      expect(csv_last_row[6]).to eq(normalizer.total_duration(csv_last_row[4], csv_last_row[5]))
    end

    def csv_read(path)
      CSV.read(path)
    end

    def expected_csv_data
      {
        headers:["timestamp", "address", "zip", "fullname", "fooduration", "barduration", "totalduration", "notes"]
      }
    end
  end
end
