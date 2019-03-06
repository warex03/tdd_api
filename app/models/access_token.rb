class AccessToken < ApplicationRecord
  belongs_to :user
  after_initialize :generate_token

  private

  def generate_token
    return if token.present? && AccessToken.exists?(token: token)
    self.token = SecureRandom.hex(10)
  end
end
