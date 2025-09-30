# spec/workers/imports/restaurant_tree_worker_spec.rb
require "rails_helper"
require "sidekiq/testing"

RSpec.describe Imports::RestaurantTreeWorker, type: :worker do
  it "runs importer and emails the user" do
    Sidekiq::Testing.inline! do
      user = create(:user, :can_import, email: "importer@example.com")
      payload = { "restaurants" => [] }

      result = Imports::RestaurantTreeImporter::Result.new(
        restaurants_created: 0, restaurants_found: 0,
        menus_created: 0, menus_found: 0,
        items_created: 0, items_found: 0,
        links_created: 0, links_updated: 0, links_unchanged: 0,
        errors: []
      )
      allow(Imports::RestaurantTreeImporter).to receive(:new).and_return(double(call: result))

      expect {
        described_class.perform_async(user.id, payload)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include("importer@example.com")
      expect(mail.subject).to match(/import has finished/i)
    end
  end
end
