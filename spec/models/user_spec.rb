# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "#can_page?" do
    subject(:user) { build(:user, page_auth: ["reports", "import"]) }

    it "returns true when the user may view the page" do
      expect(user.can_page?("import")).to be(true)
    end

    it "returns false otherwise" do
      expect(user.can_page?("settings")).to be(false)
    end
  end
end
