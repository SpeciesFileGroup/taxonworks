module Vendor
  module Gnfinder

    # ::Gnfinder::Client with a limit on the time to connect.
    #
    # The gem sets only a read timeout, so when finder.globalnames.org can't
    # be reached every request waits out the operating system's connect
    # timeout (about a minute). The gem has no option for it, so this rebuilds
    # the gem's connection (its @site) with the gem's own options plus an
    # open timeout. client_spec checks that requests actually carry it, so a
    # gem change that bypasses this fails there rather than silently.
    #
    # If the gem changes enough to break this, consider replacing it with our
    # own client: it's a single JSON POST to /api/v1/find.
    class Client < ::Gnfinder::Client

      # seconds
      OPEN_TIMEOUT = 5

      def initialize(...)
        super
        @site = RestClient::Resource.new(
          @site.url, @site.options.merge(open_timeout: OPEN_TIMEOUT), &@site.block
        )
      end
    end
  end
end
