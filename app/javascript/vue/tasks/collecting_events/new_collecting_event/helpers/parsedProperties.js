import { romanNumbers } from './romanNumbers'
import DOMPurify from 'dompurify'
import { truncateDecimal } from 'helpers/math.js'

export const parsedProperties = {
  GeographicArea: ({ ce }) => ce.geographicArea?.name,

  Dates: ({ ce }) => [
    [
      ce.start_date_day,
      romanNumbers[Number(ce.start_date_month) - 1],
      ce.start_date_year],
    [
      ce.end_date_day,
      romanNumbers[Number(ce.end_date_month) - 1],
      ce.end_date_year
    ]
  ].map(dates => dates.filter(date => date).join('.')).filter(arr => arr.length).join('\n'),

  Elevation: ({ ce }) => [
    ce.minimum_elevation,
    ce.maximum_elevation,
    ce.elevation_precision && `+/-${ce.elevation_precision}`
  ].filter(item => item).map(item => `${item}m`).join(' '),

  Time: ({ ce }) => [
    [
      ce.time_start_hour,
      ce.time_start_minute,
      ce.time_start_second
    ],
    [
      ce.time_end_hour,
      ce.time_end_minute,
      ce.time_end_second
    ]
  ].map(times =>
    times.filter(time => time).map(time => time < 10 ? `0${time}` : time).join(':')).filter(arr => arr.length).join('\n'),

  CollectorsComponent: ({ ce }) => ce.roles_attributes.map(role => role.person.cached).join('; '),

  TripCode: ({ ce, tripCode }) => DOMPurify.sanitize(tripCode.object_tag, { FORBID_TAGS: ['span'], KEEP_CONTENT: true }),

  Georeferences: ({ georeferences }) => (georeferences || [])
    .filter(geo => geo?.geo_json?.geometry?.type === 'Point')
    .map(geo => `${truncateDecimal(geo.geo_json.geometry.coordinates[1], 6)}, ${truncateDecimal(geo.geo_json.geometry.coordinates[0], 6)}`)
    .join('\n')
}
