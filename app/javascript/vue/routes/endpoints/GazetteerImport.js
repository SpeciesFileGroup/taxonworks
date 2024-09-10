import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'gazetteer_imports'
const permitParams = {}

export const GazetteerImport = {
  ...baseCRUD(controller, permitParams),

  all: () => AjaxCall('get', `/${controller}/all.json`)
}