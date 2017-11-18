class BigDecimal
  def self.try_convert(value)
    new(value, 8)
  rescue TypeError
    nil
  end
end
