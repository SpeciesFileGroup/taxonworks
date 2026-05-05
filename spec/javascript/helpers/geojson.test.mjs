// Run with:
// node --experimental-default-type=module --test spec/javascript/helpers/geojson.test.mjs

import test from 'node:test'
import assert from 'node:assert/strict'

import {
  convertToLatLongOrder,
  formatGeoJsonGeometryForDisplay
} from '../../../app/javascript/vue/helpers/geojson.js'

test('convertToLatLongOrder swaps longitude/latitude order', () => {
  assert.deepEqual(convertToLatLongOrder([-88.2434, 40.1164]), [40.1164, -88.2434])
})

test('formatGeoJsonGeometryForDisplay formats point coordinates in latitude/longitude order', () => {
  const geometry = {
    type: 'Point',
    coordinates: [-55.835014483, -27.424777147]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry),
    '[-27.424777147,-55.835014483]'
  )
})

test('formatGeoJsonGeometryForDisplay throws when geometry is missing', () => {
  assert.throws(() => formatGeoJsonGeometryForDisplay(undefined), TypeError)
})

test('formatGeoJsonGeometryForDisplay throws when coordinates are invalid', () => {
  const geometry = {
    type: 'Point',
    coordinates: null
  }

  assert.throws(() => formatGeoJsonGeometryForDisplay(geometry), TypeError)
})

test('formatGeoJsonGeometryForDisplay formats multipoint coordinates recursively', () => {
  const geometry = {
    type: 'MultiPoint',
    coordinates: [
      [-55.8, -27.4],
      [-55.7, -27.3]
    ]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry),
    '[[-27.4,-55.8],[-27.3,-55.7]]'
  )
})

test('formatGeoJsonGeometryForDisplay formats linestring coordinates recursively', () => {
  const geometry = {
    type: 'LineString',
    coordinates: [
      [-55.8, -27.4],
      [-55.7, -27.3],
      [-55.6, -27.2]
    ]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry),
    '[[-27.4,-55.8],[-27.3,-55.7],[-27.2,-55.6]]'
  )
})

test('formatGeoJsonGeometryForDisplay formats multilinestring coordinates recursively', () => {
  const geometry = {
    type: 'MultiLineString',
    coordinates: [
      [
        [-55.8, -27.4],
        [-55.7, -27.3]
      ],
      [
        [-55.6, -27.2],
        [-55.5, -27.1]
      ]
    ]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry),
    '[[[-27.4,-55.8],[-27.3,-55.7]],[[-27.2,-55.6],[-27.1,-55.5]]]'
  )
})

test('formatGeoJsonGeometryForDisplay formats polygon coordinates recursively', () => {
  const geometry = {
    type: 'Polygon',
    coordinates: [[
      [-55.8, -27.4],
      [-55.7, -27.4],
      [-55.7, -27.3],
      [-55.8, -27.4]
    ]]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry),
    '[[[-27.4,-55.8],[-27.4,-55.7],[-27.3,-55.7],[-27.4,-55.8]]]'
  )
})

test('formatGeoJsonGeometryForDisplay preserves polygon interior rings', () => {
  const geometry = {
    type: 'Polygon',
    coordinates: [
      [
        [-55.8, -27.4],
        [-55.4, -27.4],
        [-55.4, -27.0],
        [-55.8, -27.0],
        [-55.8, -27.4]
      ],
      [
        [-55.7, -27.3],
        [-55.5, -27.3],
        [-55.5, -27.1],
        [-55.7, -27.1],
        [-55.7, -27.3]
      ]
    ]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry, 500),
    '[[[-27.4,-55.8],[-27.4,-55.4],[-27,-55.4],[-27,-55.8],[-27.4,-55.8]],[[-27.3,-55.7],[-27.3,-55.5],[-27.1,-55.5],[-27.1,-55.7],[-27.3,-55.7]]]'
  )
})

test('formatGeoJsonGeometryForDisplay formats multipolygon coordinates recursively', () => {
  const geometry = {
    type: 'MultiPolygon',
    coordinates: [
      [[
        [-55.8, -27.4],
        [-55.7, -27.4],
        [-55.7, -27.3],
        [-55.8, -27.4]
      ]],
      [[
        [-55.6, -27.2],
        [-55.5, -27.2],
        [-55.5, -27.1],
        [-55.6, -27.2]
      ]]
    ]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry, 500),
    '[[[[-27.4,-55.8],[-27.4,-55.7],[-27.3,-55.7],[-27.4,-55.8]]],[[[-27.2,-55.6],[-27.2,-55.5],[-27.1,-55.5],[-27.2,-55.6]]]]'
  )
})

test('formatGeoJsonGeometryForDisplay preserves multipolygon interior rings', () => {
  const geometry = {
    type: 'MultiPolygon',
    coordinates: [
      [
        [
          [-55.8, -27.4],
          [-55.4, -27.4],
          [-55.4, -27.0],
          [-55.8, -27.0],
          [-55.8, -27.4]
        ],
        [
          [-55.7, -27.3],
          [-55.5, -27.3],
          [-55.5, -27.1],
          [-55.7, -27.1],
          [-55.7, -27.3]
        ]
      ],
      [
        [
          [-55.2, -26.8],
          [-54.8, -26.8],
          [-54.8, -26.4],
          [-55.2, -26.4],
          [-55.2, -26.8]
        ]
      ]
    ]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry, 500),
    '[[[[-27.4,-55.8],[-27.4,-55.4],[-27,-55.4],[-27,-55.8],[-27.4,-55.8]],[[-27.3,-55.7],[-27.3,-55.5],[-27.1,-55.5],[-27.1,-55.7],[-27.3,-55.7]]],[[[-26.8,-55.2],[-26.8,-54.8],[-26.4,-54.8],[-26.4,-55.2],[-26.8,-55.2]]]]'
  )
})

test('formatGeoJsonGeometryForDisplay serializes geometry collections', () => {
  const geometry = {
    type: 'GeometryCollection',
    geometries: [
      { type: 'Point', coordinates: [-55.8, -27.4] },
      { type: 'LineString', coordinates: [[-55.8, -27.4], [-55.7, -27.3]] }
    ]
  }

  assert.equal(
    formatGeoJsonGeometryForDisplay(geometry, 500),
    '[{"type":"Point","coordinates":[-55.8,-27.4]},{"type":"LineString","coordinates":[[-55.8,-27.4],[-55.7,-27.3]]}]'
  )
})

test('formatGeoJsonGeometryForDisplay truncates long output', () => {
  const geometry = {
    type: 'MultiPolygon',
    coordinates: [
      [[Array.from({ length: 20 }, (_, i) => [-55.8 + i / 100, -27.4 + i / 100])]]
    ]
  }

  const value = formatGeoJsonGeometryForDisplay(geometry, 40)

  assert.match(value, /\.\.\.$/)
  assert.equal(value.length, 43)
})
