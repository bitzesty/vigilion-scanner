class AbsoluteUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.nil? || uri?(value)
      record.errors[attribute] << "is not a valid URL"
    end
  end

  def uri?(string)
    uri = URI.parse(string)
    ["http", "https"].include?(uri.scheme)
  rescue URI::Error
    false
  end
end
