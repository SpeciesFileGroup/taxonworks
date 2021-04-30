import baseCRUD from './base'

const permitParams = {
  project_member: {
    project_id: Number,
    user_id: Number,
    is_project_administrator: Boolean
  }
}

export const ProjectMember = {
  ...baseCRUD('project_members', permitParams)
}
