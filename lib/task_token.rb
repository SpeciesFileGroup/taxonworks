# Ephemeral, encrypted, throttled tokens that let a Mobile app POST to a
# specific TaxonWorks Task (the "origin", a Task route name, e.g.
# `quick_mobile_material_task`).
#
# All token handling (encoding/decoding, cache state, throttles, live data
# checks) happens here; controllers use it only through the
# TaskTokenAuthentication concern.
#
# Lifecycle
# * .issue (session authenticated, in TaxonWorks): a 2 minute `pending`
#   token, one live per User + origin
# * .verify: every token request, returns a Result (status, stage, payload)
# * .activate: the first POST with a `pending` token swaps it, ONCE, for an
#   `active` token with a fixed lifetime (never sliding)
# * .invalidate: one origin; .invalidate_user: all of a User's tokens
#
# State lives in Rails.cache only (keys `task_token/...`, see Store) as an
# allowlist, so cache loss or eviction fails closed.
#
# Claude Code (Opus 5.5) wrote > 50% of this module.
#
module TaskToken

  # A first, scanned-from-QR token lives this long.
  PENDING_LIFETIME = 2.minutes

  # An active token lives this long unless the Task controller says otherwise.
  DEFAULT_LIFETIME = 2.hours

  # No active token may outlive this, see NONCE_LIFETIME.
  MAXIMUM_LIFETIME = 12.hours

  # The per-User nonce lives this long from the last issue, longer than any
  # token issued against it.
  NONCE_LIFETIME = 1.day

  # Requests per token per minute.
  RATE_LIMIT_PER_MINUTE = 500

  # Total requests per token, per minute of the token's lifetime.
  TOTAL_REQUESTS_PER_MINUTE_OF_LIFETIME = 500

  STATES = %w{pending active}.freeze

  # @return [Issued]
  #   token: the encrypted token, expires_at: [ActiveSupport::TimeWithZone]
  Issued = Struct.new(:token, :expires_at, keyword_init: true)

  # status: :ok, :unauthorized, :too_many_requests
  # stage: :initiation (pending token), :capture (active token), nil on failure
  # payload: the decrypted token [Hash], nil on failure
  Result = Struct.new(:status, :stage, :payload, keyword_init: true) do
    def ok?
      status == :ok
    end
  end

  # @param user_id [Integer]
  # @param project_id [Integer]
  # @param origin [String, Symbol] the Task route name
  # @param attributes [Hash] minimal named attributes, e.g. composition_id
  # @return [Issued]
  #   a pending token. Overwrites any prior token for User + origin.
  def self.issue(user_id:, project_id:, origin:, attributes: {})
    raise ArgumentError, 'user_id, project_id and origin are required' if user_id.blank? || project_id.blank? || origin.blank?

    nonce = Store.touch_nonce(user_id)
    jti = new_jti
    expires_at = Time.current + PENDING_LIFETIME

    Store.write_counter(Store.activation_key(jti), expires_in: PENDING_LIFETIME)
    Store.write_origin(user_id, origin, jti:, state: 'pending', expires_at:)

    Issued.new(
      token: Codec.encode(
        {
          'jti' => jti,
          'user_id' => user_id,
          'project_id' => project_id,
          'origin' => origin.to_s,
          'nonce' => nonce,
          'expires_at' => expires_at.iso8601,
          'attributes' => attributes.to_h.stringify_keys.compact
        }, expires_at:),
      expires_at:)
  end

  # @param token [String, nil]
  # @return [Hash, nil] the payload, nil if invalid, tampered, or expired
  def self.decode(token)
    Codec.decode(token)
  end

  # Cache state and throttle checks for one request. Does NOT check live
  # data or request params, see .live? and .ids_match?
  # @return [Result]
  def self.verify(token, origin:)
    payload = decode(token)
    return unauthorized if payload.nil? || payload['origin'] != origin.to_s

    user_id = payload['user_id']

    nonce = Store.read_nonce(user_id)
    return unauthorized if nonce.nil? || !secure_compare(nonce, payload['nonce'])

    entry = Store.read_origin(user_id, origin)
    return unauthorized if entry.nil? || !secure_compare(entry['jti'], payload['jti'])

    case entry['state']
    when 'pending'
      Result.new(status: :ok, stage: :initiation, payload:)
    when 'active'
      throttle(payload)
    else
      unauthorized
    end
  end

  # Swaps a pending token for an active one, exactly once.
  # @param payload [Hash] from a pending .verify
  # @param lifetime [ActiveSupport::Duration]
  # @return [Issued, nil] nil if already activated (or cache failure)
  def self.activate(payload, lifetime:)
    lifetime = [lifetime, MAXIMUM_LIFETIME].min

    # Only the request that moves the counter from 0 to 1 activates
    return nil unless Rails.cache.increment(Store.activation_key(payload['jti'])) == 1

    user_id = payload['user_id']
    origin = payload['origin']

    # A newer QR issued meanwhile wins
    entry = Store.read_origin(user_id, origin)
    return nil if entry.nil? || entry['jti'] != payload['jti'] || entry['state'] != 'pending'

    jti = new_jti
    expires_at = Time.current + lifetime

    Store.write_counter(Store.total_key(jti), expires_in: lifetime)
    Store.write_origin(user_id, origin, jti:, state: 'active', expires_at:)

    Issued.new(
      token: Codec.encode(payload.merge('jti' => jti, 'expires_at' => expires_at.iso8601, 'lifetime' => lifetime.to_i), expires_at:),
      expires_at:)
  end

  # @return [Hash, nil] the origin entry, `jti`, `state` and `expires_at`
  def self.status(user_id:, origin:)
    Store.read_origin(user_id, origin)
  end

  # Ends the token for User + origin.
  def self.invalidate(user_id:, origin:)
    Store.delete_origin(user_id, origin)
  end

  # Ends every token of the User (e.g. sign out, Project switch).
  def self.invalidate_user(user_id)
    Store.delete_nonce(user_id)
  end

  # @return [Boolean]
  #   true if the User exists and is not locked out, is a member of the
  #   Project, and the Composition (when in the payload) is in the Project
  def self.live?(payload)
    user = User.find_by(id: payload['user_id'])
    return false if user.nil? || user.is_flagged_for_password_reset
    return false unless ProjectMember.exists?(user_id: user.id, project_id: payload['project_id'])

    if (composition_id = payload.dig('attributes', 'composition_id'))
      return false unless Composition.where(id: composition_id, project_id: payload['project_id']).exists?
    end

    true
  end

  # @param params [Hash] the plain-text ids sent with the request
  # @return [Boolean] true if every id the token carries is sent, and agrees
  def self.ids_match?(payload, params)
    params = params.to_h.stringify_keys

    expected = {
      'user_id' => payload['user_id'],
      'project_id' => payload['project_id'],
      'composition_id' => payload.dig('attributes', 'composition_id')
    }.compact

    expected.all? { |k, v| params[k].present? && params[k].to_s == v.to_s }
  end

  # @return [Integer]
  def self.total_request_limit(lifetime)
    (lifetime / 1.minute).ceil * TOTAL_REQUESTS_PER_MINUTE_OF_LIFETIME
  end

  def self.throttle(payload)
    jti = payload['jti']

    total = Rails.cache.increment(Store.total_key(jti))
    rate = Store.increment_window(jti)

    return unauthorized if total.nil? || rate.nil?

    if rate > RATE_LIMIT_PER_MINUTE || total > total_request_limit(payload['lifetime'].to_i.seconds)
      invalidate(user_id: payload['user_id'], origin: payload['origin'])
      return Result.new(status: :too_many_requests)
    end

    Result.new(status: :ok, stage: :capture, payload:)
  end

  def self.unauthorized
    Result.new(status: :unauthorized)
  end

  def self.new_jti
    SecureRandom.uuid
  end

  def self.secure_compare(a, b)
    a.is_a?(String) && b.is_a?(String) && ActiveSupport::SecurityUtils.secure_compare(a, b)
  end

  private_class_method :throttle, :unauthorized, :new_jti, :secure_compare
end
