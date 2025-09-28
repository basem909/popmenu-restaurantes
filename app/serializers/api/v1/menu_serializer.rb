module Api
    module V1
      class MenuSerializer < Api::BaseSerializer
        attributes :id, :name, :description, :active, :starts_at, :ends_at
        attribute(:status) { |menu| menu.active ? "active" : "inactive" }
      end
    end
end
