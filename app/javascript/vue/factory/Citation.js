import { randomUUID } from '@/helpers'

export default (type) => ({
  id: undefined,
  uuid: randomUUID(),
  source_id: undefined,
  is_original: undefined,
  pages: undefined,
  citation_object_type: type,
  citation_object_id: undefined,
  isUnsaved: false
})
