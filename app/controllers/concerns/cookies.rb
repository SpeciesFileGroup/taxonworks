module Cookies
  extend ActiveSupport::Concern

  def digest_cookie(file, key)
    sha256 = Digest::SHA256.file(file)
    cookies[key] = sha256.hexdigest
  end

  def digested_cookie_exists?(file, key)
    sha256 = Digest::SHA256.file(file)
    cookies[key] == sha256.hexdigest
  end

end
