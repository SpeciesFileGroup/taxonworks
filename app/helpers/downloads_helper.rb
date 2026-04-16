module DownloadsHelper
  def download_tag(download)
    return nil if download.nil?
    "[#{download.name}] #{download.description}".html_safe
  end

  def download_link(download)
    return nil if download.nil?
    link_to(download_tag(download), download.metamorphosize)
  end

  def download_file_api_url(download)
    return nil if download.nil?
    if sessions_current_project.api_access_token
      api_v1_api_download_file_url(download, project_token: sessions_current_project.api_access_token)
    else
      nil
    end
  end

  # @return [Hash]
  #   calculated attributes used in /download responses
  def download_status(download)
    return nil if download.nil?  || !download.persisted?
    return {
      ready: download.ready?,
      expired: download.expired?
    }
  end
end
