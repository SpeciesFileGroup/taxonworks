import {
  TASK_COLLECTING_EVENT_SPATIAL_SUMMARY,
  TASK_FIELD_SYNCHRONIZE
} from '../constants/links'

export const CollectingEvent = {
  all: [TASK_COLLECTING_EVENT_SPATIAL_SUMMARY, TASK_FIELD_SYNCHRONIZE],
  ids: [TASK_COLLECTING_EVENT_SPATIAL_SUMMARY, TASK_FIELD_SYNCHRONIZE]
  /*   per: [
    {
      label: 'By collection object',
      link: '/tasks/collecting_events/filter',
      params: ['collection_object_id']
    },
    {
      label: 'By geographic area',
      link: '/tasks/collecting_events/filter',
      params: ['geographic_area_id']
    }
  ], */
}
