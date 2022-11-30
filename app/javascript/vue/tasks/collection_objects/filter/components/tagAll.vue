<template>
  <div>
    <VSpinner
      v-if="showSpinner"
      full-screen
      legend="Creating tags..."
    />
    <VBtn
      circle
      color="create"
      @click="createTags"
      :disabled="!keywordId || !ids.length"
    >
      <VIcon
        x-small
        name="label"
      />
    </VBtn>
  </div>
</template>

<script setup>
import { ref, onUnmounted } from 'vue'
import { Tag } from 'routes/endpoints'
import { CONTROLLED_VOCABULARY_TERM } from 'constants/index'
import VSpinner from 'components/spinner'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  type: {
    type: String,
    required: true
  }
})

const keywordId = ref(getDefault())
const showSpinner = ref(false)

function getDefault () {
  const defaultTag = document.querySelector('[data-pinboard-section="Keywords"] [data-insert="true"]')

  return defaultTag && defaultTag.getAttribute('data-pinboard-object-id')
}

function createTags () {
  showSpinner.value = true

  Tag.createBatch({
    object_type: props.type,
    keyword_id: keywordId.value,
    object_ids: props.ids
  }).then(() => {
    showSpinner.value = false
    TW.workbench.alert.create('Tags was successfully created', 'notice')
  })
}

function handleEvent (event) {
  if (event.detail.type === CONTROLLED_VOCABULARY_TERM) {
    keywordId.value = getDefault()
  }
}

document.addEventListener('pinboard:insert', handleEvent)

onUnmounted(() => {
  document.removeEventListener('pinboard:insert', handleEvent)
})
</script>
