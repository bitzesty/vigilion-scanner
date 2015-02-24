require 'spec_helper'

describe "When requesting a file to scan" do
  it "should accept a url and return ok" do
    post '/scan', {url: 'https://s3-eu-west-1.amazonaws.com/virus-scan-test/EICAR-AV-Test'}
    expect_json({status: 'scanning'})
  end

  it "should error if an invalid url is sent"
  # 400 bad request
end
