import { useRandomUUID } from "helpers/random"

export default () => ({
  uuid: useRandomUUID(),
  label: undefined,
  old_object_id: undefined,
  old_object_type: undefined,
  isUnsaved: false
})
