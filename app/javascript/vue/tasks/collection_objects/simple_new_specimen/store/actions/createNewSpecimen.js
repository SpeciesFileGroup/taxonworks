import ActionNames from './actionNames.js'

export default async function () {
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
    this[ActionNames.CreateIdentifier]()
  }

  if (this.otu) {
    this[ActionNames.CreateTaxonDetermination]()
  }

  this[ActionNames.GetRecent]()
  this[ActionNames.ResetStore]()
}
