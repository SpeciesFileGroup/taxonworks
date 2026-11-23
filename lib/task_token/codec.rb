# Encrypts and signs task_token payloads (AES-256-GCM, authenticated), see TaskToken.
#
# The key derives from secret_key_base, rotating it ends every live token.
#
module TaskToken::Codec

  SALT = 'task_token'.freeze

  PURPOSE = :task_token

  # @return [ActiveSupport::MessageEncryptor]
  def self.encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(
      Rails.application.key_generator.generate_key(SALT, ActiveSupport::MessageEncryptor.key_len),
      serializer: JSON
    )
  end

  # @param payload [Hash] string keys
  # @param expires_at [Time]
  # @return [String]
  def self.encode(payload, expires_at:)
    encryptor.encrypt_and_sign(payload, purpose: PURPOSE, expires_at:)
  end

  # @return [Hash, nil] nil if blank, tampered, of another purpose, or expired
  def self.decode(token)
    return nil unless token.is_a?(String) && token.present?
    payload = encryptor.decrypt_and_verify(token, purpose: PURPOSE)
    payload.is_a?(Hash) ? payload : nil
  rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature, ArgumentError, JSON::ParserError
    nil
  end

end
