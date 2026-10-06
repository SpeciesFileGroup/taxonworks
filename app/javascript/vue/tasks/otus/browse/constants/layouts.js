import { PANEL_COMPONENTS } from './components.js'

export const LAYOUT_CLASSIC = 'classic'
export const LAYOUT_TWO_COLUMN = 'twoColumn'
export const LAYOUT_CUSTOM = 'custom'

export const DEFAULT_LAYOUT = LAYOUT_TWO_COLUMN

export const RENAMED_LAYOUTS = {
  taxonPages: LAYOUT_TWO_COLUMN
}

export const PANEL_KEYS = Object.keys(PANEL_COMPONENTS)

export const MAX_COLUMNS_PER_ROW = 2

const TWO_COLUMN_MAIN = ['PanelDepictions', 'PanelType', 'NomenclatureHistory']

const TWO_COLUMN_ASIDE = [
  'PanelDistribution',
  'PanelDescendants',
  'PanelCommonNames',
  'PanelContent',
  'PanelAnnotations',
  'PanelConveyance',
  'PanelDescription'
]

const TWO_COLUMN_BELOW = PANEL_KEYS.filter(
  (key) => !TWO_COLUMN_MAIN.includes(key) && !TWO_COLUMN_ASIDE.includes(key)
)

export const LAYOUT_PRESETS = {
  [LAYOUT_CLASSIC]: {
    label: 'Classic',
    rows: [{ columns: [PANEL_KEYS] }]
  },

  [LAYOUT_TWO_COLUMN]: {
    label: 'Two-column',
    rows: [
      { columns: [TWO_COLUMN_MAIN, TWO_COLUMN_ASIDE] },
      { columns: [TWO_COLUMN_BELOW] }
    ]
  }
}

export const LAYOUT_OPTIONS = [
  { value: LAYOUT_CLASSIC, label: LAYOUT_PRESETS[LAYOUT_CLASSIC].label },
  {
    value: LAYOUT_TWO_COLUMN,
    label: LAYOUT_PRESETS[LAYOUT_TWO_COLUMN].label
  },
  { value: LAYOUT_CUSTOM, label: 'Custom' }
]
