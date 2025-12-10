import {
  NEWS_ADMINISTRATION_BLOGPOST,
  NEWS_ADMINISTRATION_WARNING,
  NEWS_ADMINISTRATION_NOTICE,
  NEWS_PROJECT_BLOGPOST,
  NEWS_PROJECT_INSTRUCTION,
  NEWS_PROJECT_NOTICE
} from '@/constants/news'

const CSS_CLASSES_BY_TYPE = {
  [NEWS_ADMINISTRATION_BLOGPOST]: 'notification-list-item-admin-blogpost',
  [NEWS_ADMINISTRATION_WARNING]: 'notification-list-item-admin-warning',
  [NEWS_ADMINISTRATION_NOTICE]: 'notification-list-item-admin-notice',
  [NEWS_PROJECT_BLOGPOST]: 'notification-list-item-project-blogpost',
  [NEWS_PROJECT_INSTRUCTION]: 'notification-list-item-project-instruction',
  [NEWS_PROJECT_NOTICE]: 'notification-list-item-project-notice'
}

export default (type) =>
  CSS_CLASSES_BY_TYPE[type] ?? 'notification-list-item-default'
