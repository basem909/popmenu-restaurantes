module Api
    module V1
      class MenuCollectionSerializer < Api::BaseSerializer
        attributes :id, :name, :active, :starts_at, :ends_at
        attribute(:status) { |menu| menu.active ? "active" : "inactive" }
      end
    end
end
