import { CollectionObject } from 'routes/endpoints'

export default function () {
  CollectionObject.reportDwc({ per: 10 }).then(({ body }) => {
    this.recentList = body
  })
}
