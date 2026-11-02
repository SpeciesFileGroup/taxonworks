import { randomUUID } from '@/helpers'
import { ROLE, ROLE_LABELS } from '../constants'

export function makeField(
  role,
  {
    rest = false,
    optional = false,
    separators = [],
    underscoresAsSpaces = false
  } = {}
) {
  return {
    id: randomUUID(),
    kind: 'field',
    role,
    rest,
    optional,
    separators,
    underscoresAsSpaces
  }
}

export function makeSeparator(value) {
  return { id: randomUUID(), kind: 'separator', value }
}

export function makeIdentifierSeparator(value, represents) {
  return { id: randomUUID(), value, represents }
}

export function defaultComposition() {
  return [makeField(ROLE.Identifier, { rest: true })]
}

export function isRestField(composition, index) {
  const item = composition[index]

  return (
    item.kind === 'field' &&
    item.rest &&
    !item.separators.length &&
    index === composition.length - 1
  )
}

export function optionalGroups(composition) {
  const firstOptional = composition.findIndex(
    (item) => item.kind === 'field' && item.optional
  )

  if (firstOptional === -1) {
    return { requiredEnd: composition.length, groups: [] }
  }

  let requiredEnd = firstOptional

  while (requiredEnd > 0 && composition[requiredEnd - 1].kind === 'separator') {
    requiredEnd--
  }

  const groups = []
  let start = requiredEnd

  composition.forEach((item, index) => {
    if (index >= requiredEnd && item.kind === 'field') {
      groups.push([start, index])
      start = index + 1
    }
  })

  return { requiredEnd, groups }
}

export function validateComposition(composition) {
  const errors = []
  const identifiers = composition.filter(
    (item) => item.kind === 'field' && item.role === ROLE.Identifier
  )

  if (identifiers.length !== 1) {
    errors.push('Add one identifier')
  }

  composition.forEach((item, index) => {
    const next = composition[index + 1]

    if (item.kind === 'field' && next?.kind === 'field') {
      errors.push(
        `Add a separator between ${ROLE_LABELS[item.role]} and ${ROLE_LABELS[next.role]}`
      )
    }
  })

  const fields = composition.filter((item) => item.kind === 'field')
  const firstOptional = fields.findIndex((item) => item.optional)

  if (firstOptional !== -1) {
    if (fields.some((item) => item.optional && item.role === ROLE.Identifier)) {
      errors.push('The identifier can not be optional')
    }

    if (fields.slice(firstOptional).some((item) => !item.optional)) {
      errors.push('Fields after an optional field must be optional')
    }

    if (composition.at(-1).kind === 'separator') {
      errors.push('Remove the separators after the last optional field')
    }
  }

  return errors
}

export function describeComposition(composition) {
  const describe = (item, index) => {
    if (item.kind === 'separator') {
      return item.value
    }

    const rest = isRestField(composition, index) ? '…' : ''

    return `{${item.role}${rest}}`
  }

  const { requiredEnd, groups } = optionalGroups(composition)
  const required = composition.slice(0, requiredEnd).map(describe).join('')

  const optional = groups.reduceRight((tail, [start, end]) => {
    const group = composition
      .slice(start, end + 1)
      .map((item, offset) => describe(item, start + offset))
      .join('')

    return `[${group}${tail}]`
  }, '')

  return required + optional
}

export function displaySeparator(value) {
  if (value === '') return '∅'

  return value.replaceAll(' ', '␣')
}

export const SAMPLE_IDENTIFIER = 'ABC123'
export const SAMPLE_IDENTIFIER_PARTS = ['ABC', '123', 'A', 'B', 'C', 'D']
const SAMPLE_VALUES = {
  [ROLE.Label]: ['dorsal'],
  [ROLE.Caption]: ['habitus'],
  [ROLE.Ignore]: ['01', '02', '03', '04']
}

export function buildExample(composition, { withOptional = true } = {}) {
  const used = { [ROLE.Ignore]: 0 }
  const result = { segments: [], identifier: '', figureLabel: '', caption: '' }
  const { requiredEnd } = optionalGroups(composition)
  const items = withOptional ? composition : composition.slice(0, requiredEnd)

  items.forEach((item) => {
    if (item.kind === 'separator') {
      result.segments.push({ id: item.id, text: item.value, role: null })
      return
    }

    let text = ''
    let value = ''

    if (item.role === ROLE.Identifier && item.separators.length) {
      text = SAMPLE_IDENTIFIER_PARTS[0]
      value = text

      item.separators.forEach((s, index) => {
        const part = SAMPLE_IDENTIFIER_PARTS[index + 1]

        text += s.value + part
        value += (typeof s.represents === 'string' ? s.represents : s.value) + part
      })
    } else if (item.role === ROLE.Identifier) {
      text = SAMPLE_IDENTIFIER
      value = text
    } else {
      const index = used[item.role] || 0
      const samples = SAMPLE_VALUES[item.role]

      text = samples[index % samples.length]
      value = text
      used[item.role] = index + 1
    }

    result.segments.push({ id: item.id, text, role: item.role })

    if (item.role === ROLE.Identifier) result.identifier = value
    if (item.role === ROLE.Label) result.figureLabel = value
    if (item.role === ROLE.Caption) result.caption = value
  })

  return result
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\/-]/g, '\\$&')
}

function stripExtension(filename) {
  const index = filename.lastIndexOf('.')

  return index > 0 ? filename.slice(0, index) : filename
}

export function compileFilenameParser(composition) {
  const characters = [
    ...new Set(
      composition
        .flatMap((item) =>
          item.kind === 'separator'
            ? [item.value]
            : item.separators.map((s) => s.value)
        )
        .join('')
    )
  ]

  const text = characters.length
    ? `[^${escapeRegExp(characters.join(''))}]+`
    : '.+'

  const fields = composition.filter((item) => item.kind === 'field')
  const fieldIndexes = new Map(
    composition
      .map((item, index) => [item, index])
      .filter(([item]) => item.kind === 'field')
      .map(([, index], fieldIndex) => [index, fieldIndex])
  )

  const itemSource = (item, index) => {
    if (item.kind === 'separator') {
      return escapeRegExp(item.value)
    }

    const fieldIndex = fieldIndexes.get(index)

    if (isRestField(composition, index)) {
      return `(?<f${fieldIndex}>.+)`
    }

    const parts = [`(?<f${fieldIndex}p0>${text})`]

    item.separators.forEach((s, partIndex) => {
      parts.push(
        escapeRegExp(s.value),
        `(?<f${fieldIndex}p${partIndex + 1}>${text})`
      )
    })

    return `(?<f${fieldIndex}>${parts.join('')})`
  }

  const { requiredEnd, groups } = optionalGroups(composition)

  const required = composition
    .slice(0, requiredEnd)
    .map(itemSource)
    .join('')

  const optional = groups.reduceRight((tail, [start, end]) => {
    const group = composition
      .slice(start, end + 1)
      .map((item, offset) => itemSource(item, start + offset))
      .join('')

    return `(?:${group}${tail})?`
  }, '')

  const source = required + optional

  const regexp = new RegExp(`^${source}$`)

  return (filename) => {
    const match = regexp.exec(stripExtension(filename))

    if (!match) return null

    const result = { identifier: null, figure_label: null, caption: null, fields: [] }

    fields.forEach((field, index) => {
      const raw = match.groups[`f${index}`] ?? null
      let value = raw

      if (raw === null) {
        result.fields.push(null)
        return
      }

      if (field.separators.length) {
        value = match.groups[`f${index}p0`]

        field.separators.forEach((s, partIndex) => {
          const separator = typeof s.represents === 'string' ? s.represents : s.value

          value += separator + match.groups[`f${index}p${partIndex + 1}`]
        })
      }

      result.fields.push(raw)

      if (field.role === ROLE.Identifier) {
        result.identifier = value
      } else if (field.role === ROLE.Label || field.role === ROLE.Caption) {
        const key = field.role === ROLE.Label ? 'figure_label' : 'caption'

        result[key] = field.underscoresAsSpaces
          ? value.replaceAll('_', ' ')
          : value
      }
    })

    return result
  }
}
