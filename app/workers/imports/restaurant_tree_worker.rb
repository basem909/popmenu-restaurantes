# app/workers/imports/restaurant_tree_worker.rb

module Imports
  # Background worker for processing restaurant import jobs
  class RestaurantTreeWorker
    include Sidekiq::Worker
    sidekiq_options queue: :imports, retry: 5

    # Process restaurant import job
    # @param user_id [Integer] ID of the user who initiated the import
    # @param payload_hash [Hash] Restaurant data to import
    def perform(user_id, payload_hash)
      user = User.find(user_id)
      result = ::Imports::RestaurantTreeImporter.new(payload_hash).call
      ImportMailer.with(user: user, result: result).import_finished.deliver_now
    end
  end
end
  