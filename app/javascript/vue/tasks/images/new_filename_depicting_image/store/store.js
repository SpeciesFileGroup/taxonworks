import { defineStore } from 'pinia'
import { computed, markRaw, ref, watch } from 'vue'
import { Image } from '@/routes/endpoints'
import { randomUUID } from '@/helpers'
import { ROLE, SEPARATORS, STATUS, UNIQUE_ROLES } from '../constants'
import {
  compileFilenameParser,
  defaultComposition,
  makeField,
  makeIdentifierSeparator,
  makeSeparator,
  validateComposition
} from '../utils/pattern'

const MATCH_DELAY = 300

export const useStore = defineStore('newFilenameDepictingImage', () => {
  const composition = ref(defaultComposition())
  const rows = ref([])

  const identifierMatches = ref({})
  const selectedId = ref(null)
  const pendingMatches = ref(0)
  const pendingIdentifiers = new Set()

  const compositionErrors = computed(() =>
    validateComposition(composition.value)
  )

  const isPatternValid = computed(() => !compositionErrors.value.length)

  const parseFilename = computed(() =>
    isPatternValid.value
      ? compileFilenameParser(composition.value)
      : null
  )

  const parsedRows = computed(
    () =>
      new Map(
        rows.value.map((row) => [
          row.uuid,
          parseFilename.value ? parseFilename.value(row.filename) : null
        ])
      )
  )

  const unresolvedIdentifiers = computed(() => [
    ...new Set(
      [...parsedRows.value.values()]
        .filter((parsed) => parsed && !(parsed.identifier in identifierMatches.value))
        .map((parsed) => parsed.identifier)
    )
  ])

  const isMatching = computed(
    () => pendingMatches.value > 0 || unresolvedIdentifiers.value.length > 0
  )

  const uploadableRows = computed(() =>
    rows.value.filter(
      (row) => !row.upload && rowMatch(row)?.status === STATUS.Matched
    )
  )

  const failedRows = computed(() =>
    rows.value.filter((row) => row.upload?.status === STATUS.Error)
  )

  const isUploading = computed(() =>
    rows.value.some((row) =>
      [STATUS.Queued, STATUS.Uploading].includes(row.upload?.status)
    )
  )

  const statusCounts = computed(() =>
    rows.value.reduce((counts, row) => {
      const status = rowStatus(row)

      counts[status] = (counts[status] || 0) + 1

      return counts
    }, {})
  )

  function findField(id) {
    return composition.value.find((item) => item.id === id)
  }

  function isRoleUsed(role) {
    return (
      UNIQUE_ROLES.includes(role) &&
      composition.value.some(
        (item) => item.kind === 'field' && item.role === role
      )
    )
  }

  function addField(role) {
    const last = composition.value.at(-1)

    if (last?.kind === 'field') {
      const separator =
        composition.value.findLast((item) => item.kind === 'separator')
          ?.value ?? SEPARATORS[0]

      composition.value.push(makeSeparator(separator))
    }

    const lastField = composition.value.findLast((item) => item.kind === 'field')

    composition.value.push(
      makeField(role, { optional: role !== ROLE.Identifier && !!lastField?.optional })
    )
  }

  function addSeparator(value) {
    composition.value.push(makeSeparator(value))
  }

  function removeCompositionItem(index) {
    const [item] = composition.value.splice(index, 1)

    if (item?.id === selectedId.value) {
      selectedId.value = null
    }
  }

  function clearComposition() {
    composition.value = []
    selectedId.value = null
  }

  function openItem(id) {
    selectedId.value = id
  }

  function closeItem() {
    selectedId.value = null
  }

  function setFieldRole(id, role) {
    const field = findField(id)

    field.role = role

    if (role === ROLE.Identifier) {
      field.optional = false
    } else {
      field.separators = []
    }

    if (role !== ROLE.Label && role !== ROLE.Caption) {
      field.underscoresAsSpaces = false
    }
  }

  function setFieldUnderscoresAsSpaces(id, value) {
    findField(id).underscoresAsSpaces = value
  }

  function setFieldOptional(id, optional) {
    const fields = composition.value.filter((item) => item.kind === 'field')
    const index = fields.findIndex((item) => item.id === id)
    const affected = optional ? fields.slice(index) : fields.slice(0, index + 1)

    affected
      .filter((item) => item.role !== ROLE.Identifier)
      .forEach((item) => {
        item.optional = optional
      })
  }

  function setFieldRest(id, rest) {
    findField(id).rest = rest
  }

  function addIdentifierSeparator(id, value) {
    findField(id).separators.push(makeIdentifierSeparator(value))
  }

  function removeIdentifierSeparator(id, separatorId) {
    const field = findField(id)

    field.separators = field.separators.filter((s) => s.id !== separatorId)
  }

  function setSeparatorRepresents(id, separatorId, represents) {
    const separator = findField(id).separators.find(
      (s) => s.id === separatorId
    )

    separator.represents = represents
  }

  function rowMatch(row) {
    if (row.upload?.match) return row.upload.match
    if (!parseFilename.value) return null

    const parsed = parsedRows.value.get(row.uuid)

    if (!parsed) {
      return {
        status: STATUS.PatternMismatch,
        identifier: null,
        figure_label: null,
        caption: null,
        collection_object_id: null,
        global_id: null
      }
    }

    const match = identifierMatches.value[parsed.identifier]
    let status = STATUS.Matching

    if (match?.ambiguous) {
      status = STATUS.Ambiguous
    } else if (match?.matched) {
      status = STATUS.Matched
    } else if (match) {
      status = STATUS.NotFound
    }

    return {
      ...parsed,
      status,
      collection_object_id: match?.collection_object_id || null,
      global_id: match?.global_id || null
    }
  }

  function rowStatus(row) {
    return row.upload?.status || rowMatch(row)?.status || STATUS.Matching
  }

  async function matchIdentifiers(identifiers) {
    identifiers.forEach((identifier) => pendingIdentifiers.add(identifier))
    pendingMatches.value++

    try {
      const { body } = await Image.filenameDepictionMatch({ identifiers })

      body.forEach((result) => {
        identifierMatches.value[result.identifier] = result
      })
    } catch {
    } finally {
      identifiers.forEach((identifier) => pendingIdentifiers.delete(identifier))
      pendingMatches.value--
    }
  }

  function matchUnresolvedIdentifiers() {
    const identifiers = unresolvedIdentifiers.value.filter(
      (identifier) => !pendingIdentifiers.has(identifier)
    )

    if (identifiers.length) {
      matchIdentifiers(identifiers)
    }
  }

  let matchTimeout = null

  function addFiles(files) {
    const newRows = files.map((file) => ({
      uuid: randomUUID(),
      file: markRaw(file),
      filename: file.name,
      thumbnail: URL.createObjectURL(file),
      upload: null
    }))

    rows.value.push(...newRows)
  }

  function findRowByFile(file) {
    return rows.value.find((row) => row.file === file)
  }

  function removeRow(row) {
    URL.revokeObjectURL(row.thumbnail)
    rows.value = rows.value.filter((r) => r.uuid !== row.uuid)
  }

  function queueRows(targetRows) {
    targetRows.forEach((row) => {
      row.upload = { status: STATUS.Queued, match: rowMatch(row) }
    })
  }

  function setUploadResponse(row, response) {
    row.upload = { ...row.upload, status: STATUS.Created, response, message: null }
  }

  function setUploadError(row, error) {
    if (error?.image_id) {
      row.upload = { ...row.upload, status: STATUS.AlreadyDepicted, message: null }
      return
    }

    const message =
      typeof error === 'string'
        ? error
        : Object.entries(error || {})
            .map(([key, messages]) => `${key} ${[messages].flat().join(', ')}`)
            .join('; ')

    row.upload = { ...row.upload, status: STATUS.Error, message }
  }

  function reset() {
    rows.value.forEach((row) => URL.revokeObjectURL(row.thumbnail))
    rows.value = []
    identifierMatches.value = {}
  }

  watch(unresolvedIdentifiers, () => {
    clearTimeout(matchTimeout)
    matchTimeout = setTimeout(matchUnresolvedIdentifiers, MATCH_DELAY)
  })

  return {
    composition,
    compositionErrors,
    failedRows,
    isMatching,
    isPatternValid,
    isUploading,
    rows,
    selectedId,
    statusCounts,
    uploadableRows,

    addField,
    addFiles,
    addIdentifierSeparator,
    addSeparator,
    clearComposition,
    closeItem,
    findField,
    findRowByFile,
    isRoleUsed,
    removeCompositionItem,
    removeIdentifierSeparator,
    openItem,
    queueRows,
    removeRow,
    reset,
    rowMatch,
    rowStatus,
    setFieldOptional,
    setFieldRest,
    setFieldRole,
    setFieldUnderscoresAsSpaces,
    setSeparatorRepresents,
    setUploadError,
    setUploadResponse
  }
})
