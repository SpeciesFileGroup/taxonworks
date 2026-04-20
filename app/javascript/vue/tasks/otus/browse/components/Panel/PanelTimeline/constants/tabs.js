export const TIMELINE_TAB_BIOLOGY = 'biology'

export const TIMELINE_TABS = [
  /*   {
    label: 'All',
    key: '',
    value: '',
    equal: true
  }, */
  {
    label: 'Nomenclature',
    key: 'history-origin',
    value: 'otu',
    equal: false
  },
  {
    label: 'Protonym',
    key: 'history-origin',
    value: 'protonym',
    equal: true
  },
  {
    label: 'OTU (biology)',
    kind: TIMELINE_TAB_BIOLOGY
  }
]

export const DEFAULT_TIMELINE_TAB = TIMELINE_TABS[0]
