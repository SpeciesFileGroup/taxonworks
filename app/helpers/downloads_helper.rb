module DownloadsHelper
  def download_tag(download)
    return nil if download.nil?
    "[#{download.name}] #{download.description}".html_safe
  end

  def download_link(download)
    return nil if download.nil?
    link_to(download_tag(download), download)
  end
end
