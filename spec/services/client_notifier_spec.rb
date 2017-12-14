require 'rails_helper'

RSpec.describe ClientNotifier do
  describe "#notify" do
    let(:scan){ create :scan }

    it "sends a post to the client" do
      request_mock = double(:request_mock)
      expect(request_mock).to receive(:on_complete)
      expect(request_mock).to receive(:run)
      expect(Typhoeus::Request).to receive(:new).with(
        scan.project.callback_url,
        hash_including(body: scan.to_json(except: :project_id))
      ).and_return(request_mock)
      ClientNotifier.new.notify scan
    end

    it "sets webhook_response" do
      request_mock = double(:request_mock)
      webhook_response = double(:webhook_response, body: "response body")
      expect(webhook_response).to receive(:success?).and_return(true)
      expect(request_mock).to receive(:on_complete).and_yield(webhook_response)
      expect(request_mock).to receive(:run)
      expect(Typhoeus::Request).to receive(:new).with(
        scan.project.callback_url,
        hash_including(body: scan.to_json(except: :project_id))
      ).and_return(request_mock)
      ClientNotifier.new.notify scan
      expect(scan.reload.webhook_response).to eq(webhook_response.body)
    end
  end
end
