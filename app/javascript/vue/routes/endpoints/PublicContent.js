import AjaxCall from '@/helpers/ajaxCall'

export const PublicContent = {
  exists: (contentId) =>
    AjaxCall('get', '/public_contents/exists', {
      params: { content_id: contentId }
    })
}
