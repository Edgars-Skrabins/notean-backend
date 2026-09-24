class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  enum :role, { user: "user", admin: "admin", owner: "owner" }, default: "user"

  validates :role, presence: true

  before_validation { self.last_active_at ||= Time.current }
end
