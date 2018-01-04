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

    skip "unicode validates addresses" do

    end

    skip "converts times in FooDuration  and BarDuration to floating points seconds format" do

    end

    skip "recalculates the TotalDuration column values" do

    end

    skip "replaces invalid UTF-8 characters with a Unicode Replacement Character" do

    end

    skip "ensures the entire CSV is in the UTF-8 character set" do

    end
  end
end
