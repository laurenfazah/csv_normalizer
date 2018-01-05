require 'csv'

class Normalizer
  attr_reader :csv_path, :data

  def initialize(csv_path)
    @csv_path = csv_path
    @data = []
  end

  def run
    read_csv
    normalize_data
    write_csv
  end

  def read_csv
    CSV.foreach(csv_path, headers: true, header_converters: :symbol).with_index do |row, index|
      @data << row.to_h
    end
  end

  def normalize_data
    @data.each do |row|
      row[:zip]           = validate_zip(row[:zip])
      row[:timestamp]     = convert_pacific_to_eastern(row[:timestamp])
      row[:fullname]      = capitalize_name(row[:fullname])
      row[:totalduration] = total_duration(row[:fooduration], row[:barduration])
    end
  end

  def write_csv
    CSV.open("./output/#{file_name}", "wb") do |csv|
      csv << @data.first.keys
    end

    @data.each do |row|
      CSV.open("./output/#{file_name}", "a+") do |csv|
        csv << row.values
      end
    end
  end

  def convert_time_iso(time)
    DateTime.parse(time).iso8601
  end

  def convert_pacific_to_eastern(time)
    begin
       (DateTime.parse(time) + (2.0/24)).iso8601
    rescue ArgumentError
    end
  end

  def validate_zip(zip)
    zip = zip.split('')
    until zip.length == 5
      zip.unshift("0")
    end
    zip.join
  end

  def capitalize_name(name)
    name.upcase
  end

  def total_duration(foo, bar)
    total = [0,0,0]
    [foo, bar].each do |time|
      hours, minutes, seconds = time.split(":")
      total[0] += hours.to_i
      total[1] += minutes.to_i
      total[2] += seconds.to_f
    end
    conform_duration(total)
  end

  private

  def file_name
    csv_path.split("/").last
  end

  def conform_duration(total)
    hours, minutes, seconds = total

    if seconds >= 60
      sec_check   = valid_sixty(seconds)
      seconds     = sec_check[:time]
      minutes     += sec_check[:rollover]
    end

    if minutes >= 60
      mins_check  = valid_sixty(minutes)
      minutes     = mins_check[:time]
      hours       += mins_check[:rollover]
    end

    format_duration([hours, minutes, seconds.round(3)])
  end

  def format_duration(times)
    seconds_int, seconds_flt = times[2].to_s.split(".")
    "#{times[0]}:#{"%02d" % times[1]}:#{"%02d" % seconds_int}.#{seconds_flt}"
  end

  def valid_sixty(time)
    {
      rollover: (time / 60).to_i,
      time: time %= 60
    }
  end
end
