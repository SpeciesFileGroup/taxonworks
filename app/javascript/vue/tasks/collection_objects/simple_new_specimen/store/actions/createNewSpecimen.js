import ActionNames from './actionNames.js'

export default async function () {
  const promises = []

  const createObjects = async () => {
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

    const co = (await this[ActionNames.CreateCollectionObject]()).body

    if (
      this.identifier &&
      this.namespace &&
      !this.createdIdentifiers.length
    ) {
      promises.push(this[ActionNames.CreateIdentifier](co.id))
    }

    if (this.otu) {
      promises.push(this[ActionNames.CreateTaxonDetermination](co.id))
    }

    this.createdCO = co
  }

  for (let i = 0; i < this.createTotal; i++) {
    await createObjects()
  }

  Promise.allSettled(promises).then(_ => {
    this[ActionNames.GetRecent]()
    this[ActionNames.ResetStore]()

    TW.workbench.alert.create('New specimen was successfully created', 'notice')
  })
}
