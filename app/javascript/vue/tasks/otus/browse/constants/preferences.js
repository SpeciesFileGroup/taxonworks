import {
  DEFAULT_LAYOUT,
  LAYOUT_CUSTOM,
  PANEL_KEYS,
  RENAMED_LAYOUTS
} from './layouts.js'

export const PREFERENCE_SCHEMA = 20260804

export const CITATIONS_PREVIEW_SIZE = 10

export const DEFAULT_PREFERENCES = {
  preferenceSchema: PREFERENCE_SCHEMA,
  sections: PANEL_KEYS,
  layout: DEFAULT_LAYOUT,
  customRows: null,
  hideEmptyPanels: false,
  timeline: {
    alwaysShowAllCitations: false
  },
  biologicalAssociations: {
    showRanks: false
  },
  filterSections: {
    and: {
      current: [
        {
          label: 'Current name',
          key: 'history-is-current-target',
          value: false,
          equal: true
        }
      ],
      time: [
        {
          label: 'First',
          key: 'history-is-first',
          value: false,
          equal: true
        },
        {
          label: 'Last',
          key: 'history-is-last',
          value: false,
          equal: true
        }
      ],
      year: [
        {
          label: 'Year',
          key: 'history-year',
          value: undefined,
          attribute: true,
          equal: true
        }
      ]
    },
    or: {
      valid: [
        {
          label: 'Valid',
          key: 'history-is-valid',
          value: false,
          equal: true
        },
        {
          label: 'Invalid',
          key: 'history-is-valid',
          value: false,
          equal: false
        }
      ],
      cite: [
        {
          label: 'Cited',
          key: 'history-is-cited',
          value: false,
          equal: true
        },
        {
          label: 'Uncited',
          key: 'history-is-cited',
          value: false,
          equal: false
        }
      ]
    },
    show: [
      {
        label: 'Notes',
        key: 'hide-notes',
        value: false
      },
      {
        label: 'Soft validation',
        key: 'hide-validations',
        value: false
      }
    ],
    topic: [
      {
        label: 'On citations',
        key: 'hide-topics',
        value: true
      }
    ]
  }
}

export function migrateTaskPreferences(stored) {
  if (!stored) return structuredClone(DEFAULT_PREFERENCES)

  if (stored.preferenceSchema >= PREFERENCE_SCHEMA) return stored

  const sections = Array.isArray(stored.sections)
    ? stored.sections.filter((key) => PANEL_KEYS.includes(key))
    : [...PANEL_KEYS]

  const customRows = customRowsFrom(stored, sections)

  return {
    ...structuredClone(DEFAULT_PREFERENCES),
    ...(stored.filterSections ? { filterSections: stored.filterSections } : {}),
    ...(stored.timeline ? { timeline: stored.timeline } : {}),
    ...(stored.biologicalAssociations
      ? { biologicalAssociations: stored.biologicalAssociations }
      : {}),
    ...(typeof stored.hideEmptyPanels === 'boolean'
      ? { hideEmptyPanels: stored.hideEmptyPanels }
      : {}),
    preferenceSchema: PREFERENCE_SCHEMA,
    sections,
    layout: layoutFrom(stored, customRows),
    customRows
  }
}

function layoutFrom(stored, customRows) {
  if (stored.layout) {
    return RENAMED_LAYOUTS[stored.layout] || stored.layout
  }

  return customRows ? LAYOUT_CUSTOM : DEFAULT_LAYOUT
}

function customRowsFrom(stored, sections) {
  if (Array.isArray(stored.customRows)) return stored.customRows

  if (Array.isArray(stored.customColumns)) {
    return [{ columns: stored.customColumns }]
  }

  return isOrderedLikeDefault(sections) ? null : [{ columns: [sections] }]
}

function isOrderedLikeDefault(sections) {
  let cursor = -1

  return sections.every((key) => {
    const index = PANEL_KEYS.indexOf(key)
    const isAfter = index > cursor

    cursor = index

    return isAfter
  })
}
