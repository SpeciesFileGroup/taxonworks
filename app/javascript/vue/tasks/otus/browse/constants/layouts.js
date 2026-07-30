import { PANEL_COMPONENTS } from './components.js'

export const LAYOUT_CLASSIC = 'classic'
export const LAYOUT_OVERVIEW = 'overview'
export const LAYOUT_CUSTOM = 'custom'

export const DEFAULT_LAYOUT = LAYOUT_OVERVIEW

export const RENAMED_LAYOUTS = {
  taxonPages: LAYOUT_OVERVIEW
}

export const PANEL_KEYS = Object.keys(PANEL_COMPONENTS)

export const MAX_COLUMNS_PER_ROW = 2

const OVERVIEW_MAIN = ['PanelType', 'NomenclatureHistory']

const OVERVIEW_ASIDE = [
  'PanelDistribution',
  'PanelDescendants',
  'PanelCommonNames',
  'PanelContent',
  'PanelAnnotations',
  'PanelConveyance'
]

const OVERVIEW_BELOW = PANEL_KEYS.filter(
  (key) => !OVERVIEW_MAIN.includes(key) && !OVERVIEW_ASIDE.includes(key)
)

export const LAYOUT_PRESETS = {
  [LAYOUT_CLASSIC]: {
    label: 'Classic',
    rows: [{ columns: [PANEL_KEYS] }]
  },

  [LAYOUT_OVERVIEW]: {
    label: 'Overview',
    rows: [
      { columns: [OVERVIEW_MAIN, OVERVIEW_ASIDE] },
      { columns: [OVERVIEW_BELOW] }
    ]
  }
}

export const LAYOUT_OPTIONS = [
  { value: LAYOUT_CLASSIC, label: LAYOUT_PRESETS[LAYOUT_CLASSIC].label },
  { value: LAYOUT_OVERVIEW, label: LAYOUT_PRESETS[LAYOUT_OVERVIEW].label },
  { value: LAYOUT_CUSTOM, label: 'Custom' }
]
