require 'date'

module AlwaysBeContributing
  # Contribution is a basic struct that knows how to parse
  # itself out of the raw values provided in GitHub's JSON
  class Contribution < Struct.new(:date, :value)
    def self.from_raw(raw)
      AlwaysBeContributing::Contribution.new(raw[0], raw[1])
    end

    def initialize(date, value)
      self.date = Date.parse(date)
      self.value = value
    end
  end
end
