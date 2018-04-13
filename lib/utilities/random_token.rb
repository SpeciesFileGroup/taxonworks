module Utilities::RandomToken
  # @return [String]
  def self.generate
    SecureRandom.urlsafe_base64
  end

  # @param [String] token
  # @return [Digest::SHA1]
  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
end
