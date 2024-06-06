<template>
  <button
    type="button"
    ref="saveButtonRef"
    class="button normal-input button-submit create-new-combination"
    :disabled="!validateCreate()"
    @click="save()"
  >
    {{ newCombination.hasOwnProperty('id') ? 'Update' : 'Create' }}
  </button>
</template>

<script setup>
import { ref } from 'vue'
import { Combination } from '@/routes/endpoints'
import { EXTEND_PARAMS } from '../constants/extend.js'
import platformKey from '@/helpers/getPlatformKey'
import useHotkey from 'vue3-hotkey'

const props = defineProps({
  newCombination: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['processing', 'save', 'success'])

const saveButtonRef = ref()
const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      save()
    }
  }
])

useHotkey(shortcuts.value)

function validateCreate() {
  return props.newCombination.protonyms.genus
}

function setFocus() {
  if (validateCreate()) {
    saveButtonRef.value.focus()
  }
}

function save() {
  if (validateCreate()) {
    props.newCombination?.id ? update(props.newCombination.id) : create()
  }
}

function createRecordCombination() {
  const keys = Object.keys(props.newCombination.protonyms)
  const combination = {
    verbatim_name: props.newCombination.verbatim_name,
    origin_citation_attributes: props.newCombination?.origin_citation_attributes
  }

  keys.forEach((rank) => {
    if (props.newCombination.protonyms[rank]) {
      combination[`${rank}_id`] = props.newCombination.protonyms[rank].id
    }
  })

  return combination
}

function create() {
  emit('processing', true)

  Combination.create({
    combination: createRecordCombination(),
    ...EXTEND_PARAMS
  }).then(
    ({ body }) => {
      emit('save', body)
      emit('processing', false)
      emit('success', true)
      TW.workbench.alert.create(
        'New combination was successfully created.',
        'notice'
      )
    },
    ({ body }) => {
      emit('processing', false)
      TW.workbench.alert.create(
        `Something went wrong: ${JSON.stringify(body)}`,
        'error'
      )
    }
  )
}

function update(id) {
  emit('processing', true)
  Combination.update(id, {
    combination: createRecordCombination(),
    ...EXTEND_PARAMS
  }).then(({ body }) => {
    emit('save', body)
    emit('processing', false)
    emit('success', true)
    TW.workbench.alert.create(
      'New combination was successfully updated.',
      'notice'
    )
  })
}

defineExpose({
  setFocus
})
</script>
