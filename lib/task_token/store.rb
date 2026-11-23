# task_token state in Rails.cache, see TaskToken. Keys are prefixed `task_token/`.
#
# * origin/<user_id>/<origin>: { jti:, state:, expires_at: }, ONE per User + origin
# * nonce/<user_id>: random, ONE per User, in every token of the User
# * activation/<jti>, total/<jti>, rate/<jti>/<minute>: integer counters
#
# Counters are written (0, raw) before they are incremented: Solid Cache
# increments atomically only an existing key. A nil read or increment is a
# cache failure, callers fail closed.
#
module TaskToken::Store

  PREFIX = 'task_token'.freeze

  def self.origin_key(user_id, origin)
    "#{PREFIX}/origin/#{user_id}/#{origin}"
  end

  def self.nonce_key(user_id)
    "#{PREFIX}/nonce/#{user_id}"
  end

  def self.activation_key(jti)
    "#{PREFIX}/activation/#{jti}"
  end

  def self.total_key(jti)
    "#{PREFIX}/total/#{jti}"
  end

  def self.rate_key(jti, time = Time.current)
    "#{PREFIX}/rate/#{jti}/#{time.to_i / 60}"
  end

  # @return [Hash, nil]
  def self.read_origin(user_id, origin)
    v = Rails.cache.read(origin_key(user_id, origin))
    v.is_a?(Hash) ? v : nil
  end

  def self.write_origin(user_id, origin, jti:, state:, expires_at:)
    Rails.cache.write(
      origin_key(user_id, origin),
      { 'jti' => jti, 'state' => state, 'expires_at' => expires_at.iso8601 },
      expires_at:
    )
  end

  def self.delete_origin(user_id, origin)
    Rails.cache.delete(origin_key(user_id, origin))
  end

  # @return [String, nil]
  def self.read_nonce(user_id)
    Rails.cache.read(nonce_key(user_id))
  end

  # Creates the nonce if absent (never a counter, so an evicted then
  # recreated nonce can not match an old token), and extends its life.
  # @return [String]
  def self.touch_nonce(user_id)
    nonce = read_nonce(user_id) || SecureRandom.urlsafe_base64(32)
    Rails.cache.write(nonce_key(user_id), nonce, expires_in: TaskToken::NONCE_LIFETIME)
    nonce
  end

  def self.delete_nonce(user_id)
    Rails.cache.delete(nonce_key(user_id))
  end

  def self.write_counter(key, expires_in:, unless_exist: false)
    Rails.cache.write(key, 0, raw: true, expires_in:, unless_exist:)
  end

  # The window counter is created by the first request of the minute. Two
  # requests may both create it, undercounting by at most one.
  # @return [Integer, nil]
  def self.increment_window(jti)
    key = rate_key(jti)
    write_counter(key, expires_in: 2.minutes, unless_exist: true)
    Rails.cache.increment(key)
  end

end
