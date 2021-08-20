import ajaxCall from 'helpers/ajaxCall'

const GetMetadata = () => ajaxCall('get', '/hub/tasks?category=source')

const GetMetadataSource = () => ajaxCall('get', '/metadata/Source')

const GetMetadataProjectSource = () => ajaxCall('get', '/metadata/ProjectSource')

export {
  GetMetadata,
  GetMetadataSource,
  GetMetadataProjectSource
}