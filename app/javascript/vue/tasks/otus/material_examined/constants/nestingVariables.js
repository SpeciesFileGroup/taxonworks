// Available nesting variables for material examined rendering.
// Order matches Utilities::MaterialExamined::LOOP_VARIABLES keys.
export const NESTING_VARIABLES = [
  { key: 'type_status',          label: 'Type status' },
  { key: 'country',              label: 'Country' },
  { key: 'state',                label: 'State / Province' },
  { key: 'county',               label: 'County' },
  { key: 'repository',           label: 'Repository' },
  { key: 'identifier',           label: 'Identifier' },
  { key: 'month_range',          label: 'Month range' },
  { key: 'sex',                  label: 'Sex' },
  { key: 'stage',                label: 'Life stage' },
  { key: 'total',                label: 'Total' }
]

// Default order matches Utilities::MaterialExamined::DEFAULT_ORDER
export const DEFAULT_NESTING_ORDER = [
  'type_status',
  'country',
  'state',
  'county',
  'month_range',
  'total',
  'identifier',
  'stage',
  'sex',
  'repository'
]
