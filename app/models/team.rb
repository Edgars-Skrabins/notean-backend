class Team < ApplicationRecord
  has_secure_password

  has_many :memberships
  has_many :users, through: :memberships
end
