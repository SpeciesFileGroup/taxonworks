module DownloadsHelper
  def download_tag(download)
    return nil if download.nil?
    "[#{download.name}] #{download.description}".html_safe
  end

  def download_link(download)
    return nil if download.nil?
    link_to(download_tag(download), download)
  end

  def download_file_api_url(download)
    return nil if download.nil?
    if sessions_current_project.api_access_token
      api_v1_api_download_file_url(download, project_token: sessions_current_project.api_access_token)
    else
      nil
    end
  end
end
