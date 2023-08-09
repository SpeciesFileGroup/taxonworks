import baseCRUD, { annotations } from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'import_datasets'
const permitParams = {}

export const ImportDataset = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  all: () => AjaxCall('get', '/tasks/dwca_import/index.json')
}
