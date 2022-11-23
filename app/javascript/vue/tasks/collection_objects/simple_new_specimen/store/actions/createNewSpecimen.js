export default async function () {
  if (
    !this.createdCE &&
    (
      this.collectingEvent.verbatim_label ||
      this.collectingEvent.verbatim_locality ||
      this.geographicArea
    )
  ) {
    await this.createCollectingEvent()
  }

  this.createdCO = (await this.createCollectionObject()).body

  if (
    this.identifier &&
    this.namespace &&
    !this.createdIdentifiers.length
  ) {
    this.createIdentifier()
  }

  if (this.otu) {
    this.createTaxonDetermination()
  }

  this.resetStore()
}
