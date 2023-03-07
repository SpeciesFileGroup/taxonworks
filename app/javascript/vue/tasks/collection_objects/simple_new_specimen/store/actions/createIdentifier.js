import { Identifier } from 'routes/endpoints'
import {
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  COLLECTION_OBJECT
} from 'constants/index'

export default function (coId) {
  const payload = {
    identifier: this.identifier,
    namespace_id: this.namespace.id,
    type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
    identifier_object_id: coId,
    identifier_object_type: COLLECTION_OBJECT
  }

  return Identifier.create({ identifier: payload })
}
