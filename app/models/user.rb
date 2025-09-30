class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  # page_auth is a simple string array (JSONB)
  def can_page?(key)
    Array(page_auth).map!(&:to_s).include?(key.to_s)
  end
end
