import { DEFAULT_LAYOUT, PANEL_KEYS } from './layouts.js'

export const PREFERENCE_SCHEMA = 20261006

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
  if (!stored || !(stored.preferenceSchema >= PREFERENCE_SCHEMA)) {
    return structuredClone(DEFAULT_PREFERENCES)
  }

  return stored
}
