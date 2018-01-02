require './lib/normalizer'

RSpec.describe Normalizer do
  let(:working_sample_csv_path) { "./data/sample.csv" }
  let(:broken_sample_csv_path) { "./data/sample-with-broken-utf8.csv" }
  let(:normalizer) { described_class.new(working_sample_csv_path) }

  it "exists" do
    expect(normalizer).to be_truthy
    expect(normalizer.class).to eq(Normalizer)
  end

  it "has readable CSV file path" do
    expect(normalizer.csv_path).to eq(working_sample_csv_path)
  end
end
