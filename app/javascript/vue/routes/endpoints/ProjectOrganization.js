import baseCRUD from './base'

const permitParams = {
  project_organization: {
    organization_id: Number
  }
}

export const ProjectOrganization = {
  ...baseCRUD('project_organizations', permitParams)
}
