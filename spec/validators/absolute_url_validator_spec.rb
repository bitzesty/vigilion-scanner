require 'rails_helper'

RSpec.describe AbsoluteUrlValidator do
  subject(:validator){ AbsoluteUrlValidator.new(attributes: :url) }

  describe "#validate_each" do
    let(:record){ OpenStruct.new(errors: { url: []}) }

    it "allows http" do
      validator.validate_each(record, :url, "http://www.google.com")
      expect(record.errors[:url]).to be_empty
    end

    it "allows https" do
      validator.validate_each(record, :url, "https://www.google.com")
      expect(record.errors[:url]).to be_empty
    end

    it "rejects relative urls" do
      validator.validate_each(record, :url, "/relative/url")
      expect(record.errors[:url]).not_to be_empty
    end

    it "rejects wrong URIs" do
      validator.validate_each(record, :url, "http:// any string")
      expect(record.errors[:url]).not_to be_empty
    end
  end
end
