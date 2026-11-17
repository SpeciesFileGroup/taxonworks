import { randomHue } from '@/helpers'

export function fragmentConveyances(conveyances) {
  return conveyances.filter(
    ({ start_time, end_time }) => start_time != null && end_time != null
  )
}

export function regionColorFor(conveyances, conveyanceId) {
  const index = fragmentConveyances(conveyances).findIndex(
    ({ id }) => id === conveyanceId
  )

  return index === -1 ? null : randomHue(index + 1)
}

export function regionFillFor(conveyances, conveyanceId) {
  const color = regionColorFor(conveyances, conveyanceId)

  return color ? `color-mix(in srgb, ${color} 45%, transparent)` : null
}
