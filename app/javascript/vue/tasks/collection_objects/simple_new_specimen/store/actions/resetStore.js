import incrementIdentifier from '@/tasks/digitize/helpers/incrementIdentifier'

export default function () {
  const { collectingEvent, total, ...rest } = this.settings.lock

  for (const key in rest) {
    const isLocked = this.settings.lock[key]

    if (!isLocked) {
      this.$patch({ [key]: undefined })
    }
  }

  if (!collectingEvent) {
    this.$patch({
      collectingEvent: {
        verbatim_label: undefined,
        verbatim_locality: undefined
      },
      geographicArea: undefined,
      createdCE: undefined
    })
  }

  if (!total) {
    this.total = 1
  }

  this.identifier = this.settings.increment
    ? incrementIdentifier(this.identifier, this.createTotal)
    : undefined
}
