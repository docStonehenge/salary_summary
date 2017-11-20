class Date
  def self.try_convert(value)
    parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
