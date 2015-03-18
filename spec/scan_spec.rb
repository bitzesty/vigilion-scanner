require "spec_helper"

describe "When requesting a file to scan" do
  # TODO: Should mock out the queue
  it "should accept a url and return 201 with status scanning" do
    post "/scan", url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/EICAR-AV-Test"

    expect_status(201)
    scan = ::Scan.first

    expect_json(id: scan.id, status: scan.status)
  end

  it "should error if an invalid url is sent" do
    post "/scan", file: "wtf? this isn't the param"
    expect_status(400)
  end

  # http://www.eicar.org/85-0-Download.html
  it "should detect EICAR virus" do
    scan = ::Scan.create url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/EICAR-AV-Test"
    scan.virus_check
    expect(scan.status).to eq("infected")
    expect(scan.result).to eq("Eicar-Test-Signature FOUND")
  end

  it "should detect EICAR virus in a zip" do
    scan = ::Scan.create url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/eicar_com.zip"
    scan.virus_check
    expect(scan.status).to eq("infected")
    expect(scan.result).to eq("Eicar-Test-Signature FOUND")
  end

  it "should detect EICAR virus in nested zips" do
    scan = ::Scan.create url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/eicarcom2.zip"
    scan.virus_check
    expect(scan.status).to eq("infected")
    expect(scan.result).to eq("Eicar-Test-Signature FOUND")
  end

  it "should pass a non virus file" do
    scan = ::Scan.create url: "https://s3-eu-west-1.amazonaws.com/virus-scan-test/pdf-sample.pdf"
    scan.virus_check
    expect(scan.status).to eq("clean")
    expect(scan.result).to eq("OK")
  end
end
