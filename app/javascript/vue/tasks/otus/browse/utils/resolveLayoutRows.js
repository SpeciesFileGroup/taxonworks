import {
  LAYOUT_CUSTOM,
  LAYOUT_PRESETS,
  DEFAULT_LAYOUT,
  MAX_COLUMNS_PER_ROW,
  PANEL_KEYS
} from '../constants/layouts.js'

/**
 * The full panel arrangement for a layout: every known panel key, in reading
 * order, laid out as rows of one or two columns. Visibility is not applied
 * here, so the layout settings modal can list disabled panels in the position
 * they would occupy once turned back on.
 *
 * Panels missing from a stored custom arrangement are appended to the last row,
 * so panels added to the task later surface at the bottom of the page instead
 * of disappearing.
 *
 * @param {Object} preference
 * @param {String} preference.layout - preset id
 * @param {Object[]} [preference.customRows] - stored custom arrangement
 * @returns {Object[]} rows shaped as `{ columns: [[panelKey, …], …] }`
 */
export function arrangementForLayout({ layout, customRows } = {}) {
  const rows =
    layout === LAYOUT_CUSTOM
      ? sanitizeRows(customRows)
      : cloneRows(
          (LAYOUT_PRESETS[layout] || LAYOUT_PRESETS[DEFAULT_LAYOUT]).rows
        )

  const placed = new Set(flattenRows(rows))
  const missing = PANEL_KEYS.filter((key) => !placed.has(key))

  if (missing.length) {
    const lastRow = rows[rows.length - 1]

    lastRow.columns[0] = [...lastRow.columns[0], ...missing]
  }

  return rows
}

/**
 * The rows to render: the layout arrangement narrowed to enabled panels.
 *
 * A preset owns order and the row/column split, `sections` owns visibility, so
 * switching presets never turns panels off and toggling a panel never depends
 * on the active preset.
 *
 * Empty columns and rows are kept; rank based filtering happens at render time
 * and is what ultimately decides whether they are dropped.
 *
 * @param {Object} preference
 * @param {String} preference.layout - preset id
 * @param {String[]} preference.sections - enabled panel keys
 * @param {Object[]} [preference.customRows] - stored custom arrangement
 * @returns {Object[]} rows shaped as `{ columns: [[panelKey, …], …] }`
 */
export function resolveLayoutRows({ layout, sections, customRows } = {}) {
  const enabled = new Set(
    (sections || []).filter((key) => PANEL_KEYS.includes(key))
  )

  return arrangementForLayout({ layout, customRows }).map((row) => ({
    columns: row.columns.map((column) =>
      column.filter((key) => enabled.has(key))
    )
  }))
}

/**
 * Coerces a stored arrangement into the expected shape, dropping unknown and
 * duplicated keys. Columns beyond the maximum are merged into the last allowed
 * one rather than truncated, so a hand edited preference cannot lose panels.
 */
export function sanitizeRows(rows) {
  const seen = new Set()

  const sanitized = (Array.isArray(rows) ? rows : []).map((row) => {
    const columns = (Array.isArray(row?.columns) ? row.columns : []).map(
      (column) =>
        (Array.isArray(column) ? column : []).filter((key) => {
          if (!PANEL_KEYS.includes(key) || seen.has(key)) return false

          seen.add(key)

          return true
        })
    )

    return { columns: capColumns(columns) }
  })

  return sanitized.length ? sanitized : [{ columns: [[]] }]
}

export function flattenRows(rows) {
  return rows.flatMap((row) => row.columns.flat())
}

export function cloneRows(rows) {
  return rows.map((row) => ({ columns: row.columns.map((column) => [...column]) }))
}

function capColumns(columns) {
  if (!columns.length) return [[]]
  if (columns.length <= MAX_COLUMNS_PER_ROW) return columns

  const kept = columns.slice(0, MAX_COLUMNS_PER_ROW - 1)
  const merged = columns.slice(MAX_COLUMNS_PER_ROW - 1).flat()

  return [...kept, merged]
}
