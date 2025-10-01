# frozen_string_literal: true

require "rails_helper"

RSpec.describe PermittedAttributes do
  describe ".for" do
    it "returns the friendly menu whitelist" do
      expect(described_class.for("menu")).to match_array(%i[name description active starts_at ends_at])
    end

    it "returns the menu item whitelist" do
      expect(described_class.for("menu_item")).to match_array(%i[name description price currency active])
    end

    it "falls back to an empty list for unknown resources" do
      expect(described_class.for("unknown")).to eq([])
    end
  end
end
