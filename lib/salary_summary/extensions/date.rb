class Date
  def self.try_convert(value)
    parse(value)
  rescue ArgumentError, TypeError
    nil
  end
end
