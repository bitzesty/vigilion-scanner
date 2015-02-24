require 'spec_helper'

describe "When requesting a file to scan" do
  it "should accept a url and return 201 with status scanning" do
    post "/scan", { url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/EICAR-AV-Test" }

    expect_status(201)
    expect_json(id: ::Scan.first.id, status: "scanning")
  end

  it "should error if an invalid url is sent" do
    post "/scan", {file: "wtf? this isn't the param"}
    expect_status(400)
  end
end
