import { Identifier } from 'routes/endpoints'
import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from 'constants/index'

export default function () {
  if (!this.identifier || !this.namespace) {
    this.createdIdentifiers = []
    return
  }

  Identifier.where({
    type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
    namespace_id: this.namespace.id,
    identifier: this.identifier
  }).then(({ body }) => {
    this.createdIdentifiers = body
  })
}
