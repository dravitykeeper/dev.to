require "rails_helper"

RSpec.describe Search::RemoveFromElasticsearchIndexWorker, type: :worker do
  let(:worker) { subject }
  let(:search_class) { Search::Tag }

  include_examples "#enqueues_on_correct_queue", "medium_priority", ["SearchClass", 1]

  it "deletes document for given search class" do
    allow(search_class).to receive(:delete_document)
    described_class.new.perform(search_class.to_s, 1)
    expect(search_class).to have_received(:delete_document).with(1)
  end

  context "when document is not found" do
    it "raises error" do
      expect { described_class.new.perform(search_class.to_s, 1) }.to raise_error(
        Search::Errors::Transport::NotFound,
      )
    end

    it "does not raise error if removing a Reaction" do
      expect { described_class.new.perform("Search::Reaction", 1) }.not_to raise_error(
        Search::Errors::Transport::NotFound,
      )
    end
  end
end
