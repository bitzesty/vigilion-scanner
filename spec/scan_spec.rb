require 'spec_helper'

describe "When requesting a file to scan" do
  it "should accept a url and return 201 with status scanning" do
    post "/scan", { url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/EICAR-AV-Test" }

    expect_status(201)
    scan = ::Scan.first
    expect_json(id: scan.id, status: scan.status)
  end

  it "should error if an invalid url is sent" do
    post "/scan", {file: "wtf? this isn't the param"}
    expect_status(400)
  end

  it "should detect a virus" do
    scan = ::Scan.create url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/EICAR-AV-Test"
    scan.virus_check
    expect(scan.status).to eq("infected")
    expect(scan.message).to eq("Eicar-Test-Signature FOUND")
  end

  it "should pass a non virus file" do
    scan = ::Scan.create url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/pdf-sample.pdf"
    scan.virus_check
    expect(scan.status).to eq("clean")
    expect(scan.message).to eq("OK")
  end
end
