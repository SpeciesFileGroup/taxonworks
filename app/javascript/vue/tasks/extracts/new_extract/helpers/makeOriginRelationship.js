import { randomUUID } from '@/helpers'

export default () => ({
  uuid: randomUUID(),
  label: undefined,
  old_object_id: undefined,
  old_object_type: undefined,
  isUnsaved: false
})
