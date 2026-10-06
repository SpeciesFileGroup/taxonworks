import { STRIP_PRESETS } from '../constants'

// The strip preset is applied first, then each active modifier in order. Invalid regular
// expressions are skipped so a half-typed pattern never breaks the page.
//
// @param name [String] the OTU name
// @param stripPreset [String, null] value of the selected STRIP_PRESETS entry
// @param modifiers [Array] [{ active, pattern, replacement }]
// @return [String]
export default function applyRules(name, stripPreset, modifiers = []) {
  let result = name || ''

  const preset = STRIP_PRESETS.find((p) => p.value === stripPreset)

  if (preset?.pattern) {
    result = replace(result, preset.pattern, '')
  }

  for (const modifier of modifiers) {
    if (!modifier.active || !modifier.pattern) continue
    result = replace(result, modifier.pattern, modifier.replacement || '')
  }

  return result.trim()
}

function replace(value, pattern, replacement) {
  try {
    return value.replace(new RegExp(pattern, 'g'), replacement)
  } catch {
    // Invalid regex, skip
    return value
  }
}
