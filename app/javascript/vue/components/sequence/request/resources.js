import ajaxCall from '@/helpers/ajaxCall'

const CreateSequence = function (sequence) {
  return ajaxCall('post', `/sequences`, { sequence })
}

export { CreateSequence }
