import BROWSE_SECTIONS from './components.js'

export default {
  preferenceSchema: 20260205,
  sections: Object.keys(BROWSE_SECTIONS),
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
