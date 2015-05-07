require "kartograph"

class ScanMapping
  include Kartograph::DSL

  kartograph do
    mapping Scan # The object we're mapping

    scoped :read do
      property :id
      property :uuid
      property :status
      property :result
      property :md5
      property :sha1
      property :sha256
      property :duration
    end

    scoped :create do
      property :id
      property :uuid
      property :status
    end
  end
end
