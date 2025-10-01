# app/workers/imports/restaurant_tree_worker.rb

module Imports
  # Background worker for processing restaurant import jobs
  class RestaurantTreeWorker
    include Sidekiq::Worker
    sidekiq_options queue: :imports, retry: 5

    # Process restaurant import job
    # @param user_id [Integer] ID of the user who initiated the import
    # @param payload_hash [Hash] Restaurant data to import
    # @return [void]
    def perform(user_id, payload_hash)
      user = User.find(user_id)
      importer = ::Imports::RestaurantTreeImporter.new(payload_hash)

      result = importer.call

      Rails.logger.info(
        message: "imports.restaurant_tree_worker.completed",
        user_id: user_id,
        success: result.success?,
        errors_count: result.errors.size
      )

      ImportMailer.with(user: user, result: result).import_finished.deliver_now
    rescue => e
      Rails.logger.error(
        message: "imports.restaurant_tree_worker.failed",
        user_id: user_id,
        error: e.class.name,
        error_message: e.message,
        backtrace: Array(e.backtrace).first(5)
      )
      raise
    end
  end
end
  
