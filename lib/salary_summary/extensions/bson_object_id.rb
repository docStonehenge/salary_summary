module BSON
  class ObjectId
    def self.try_convert(value)
      from_string(value)
    rescue Invalid
      nil
    end
  end
end
