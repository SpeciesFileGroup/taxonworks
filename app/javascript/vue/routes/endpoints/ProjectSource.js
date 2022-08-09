import baseCRUD from './base'

const controller = 'project_sources'
const permitParams = {
  project_source: {
    source_id: Number,
    project_id: Number
  }
}

export const ProjectSource = {
  ...baseCRUD(controller, permitParams)
}
