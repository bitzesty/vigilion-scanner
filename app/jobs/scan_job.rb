class ScanJob
  include Shoryuken::Worker

  shoryuken_options queue: -> { "#{ ENV['SQS_QUEUE'] }" }, auto_delete: true

  shoryuken_options body_parser: :json

  def perform(sqs_msg, hash)
    puts sqs_msg, hash
    uid = hash['uid']
    Scan.find(uid)
  end

end
