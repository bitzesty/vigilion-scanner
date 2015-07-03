require 'rails_helper'

RSpec.describe ClientNotifier do
  describe "#notify" do
    let(:scan){ create :scan }

    it "sends a post to the client" do
      expect(Typhoeus).to receive(:post).with(
        scan.project.callback_url,
        hash_including(body: scan.to_json(except: :project_id)))
      ClientNotifier.new.notify scan
    end
  end
end
