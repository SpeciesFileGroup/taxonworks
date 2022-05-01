
# Ripped from http://collectiveidea.com/blog/archives/2012/01/27/testing-file-downloads-with-capybara-and-chromedriver/
module Features
  module Downloads

    TIMEOUT = 20
    PATH = Rails.root.join("tmp/browser-downloads#{ENV['TEST_ENV_NUMBER']}")

    extend self

    def downloads
      Dir[PATH.join('*')]
    end

    def download
      downloads.first
    end

    def download_content
      wait_for_download
      File.read(download)
    end

    def wait_for_download
      Timeout.timeout(TIMEOUT) do
        sleep 0.1 until downloaded?
      end
      sleep 0.1 # not originally here, but seems to resolve the issue with non-determinant returns
    end

    def downloaded?
      !downloading? && downloads.any?
    end

    def downloading?
      downloads.grep(/\.crdownload$/).any?
    end

    def clear_downloads
      FileUtils.rm_f(downloads)
    end
  end
end

