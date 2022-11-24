import ActionNames from './actionNames.js'

export default async function () {
  const promises = []

  if (
    !this.createdCE &&
    (
      this.collectingEvent.verbatim_label ||
      this.collectingEvent.verbatim_locality ||
      this.geographicArea
    )
  ) {
    await this[ActionNames.CreateCollectingEvent]()
  }

  this.createdCO = (await this[ActionNames.CreateCollectionObject]()).body

  if (
    this.identifier &&
    this.namespace &&
    !this.createdIdentifiers.length
  ) {
    promises.push(this[ActionNames.CreateIdentifier]())
  }

  if (this.otu) {
    promises.push(this[ActionNames.CreateTaxonDetermination]())
  }

  Promise.allSettled(promises).then(_ => {
    this[ActionNames.GetRecent]()
    this[ActionNames.ResetStore]()
  })
}
