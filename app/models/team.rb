class Team < ApplicationRecord
  has_secure_password

  has_many :memberships
  has_many :users, through: :memberships

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  before_validation :generate_code, on: :create

  private

  def generate_code
    self.code ||= loop do
      candidate = SecureRandom.alphanumeric(32)
      break candidate unless Team.exists?(code: candidate)
    end
  end
end
