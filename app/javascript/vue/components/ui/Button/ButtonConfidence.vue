<template>
  <div v-if="keywordId && !isLoading">
    <tippy
      animation="scale"
      placement="bottom"
      size="small"
      inertia
      arrow
    >
      <template #content>
        <p>
          {{ confidenceItem ? 'Remove' : 'Create' }} confidence:
          {{ getDefaultConfidenceElement().firstChild.firstChild.textContent }}.
          <br />
          {{ totalUsed ? `Used already  on ${totalUsed} objects` : '' }}
        </p>
      </template>

      <VBtn
        circle
        :color="confidenceItem ? 'destroy' : 'create'"
        @click="
          () => {
            confidenceItem ? deleteConfidence() : createConfidence()
          }
        "
      >
        <VIcon
          color="white"
          name="confidence"
          x-small
        />
      </VBtn>
    </tippy>
  </div>
  <VBtn
    v-else
    circle
    color="disabled"
  >
    <VIcon
      color="white"
      name="confidence"
      x-small
    />
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { Tippy } from 'vue-tippy'
import { Confidence } from '@/routes/endpoints'
import { watch, onBeforeMount, onBeforeUnmount, ref } from 'vue'
import { CONTROLLED_VOCABULARY_TERM } from '@/constants'
import { getPagination } from '@/helpers'

const props = defineProps({
  globalId: {
    type: String,
    required: true
  },

  tooltip: {
    type: Boolean,
    default: true
  },

  count: {
    type: [Number, String],
    default: undefined
  }
})

const keywordId = ref(getDefaultConfidence())
const totalUsed = ref(0)
const confidenceItem = ref(null)
const isLoading = ref(false)

watch(
  () => props.count,
  (newVal) => {
    totalUsed.value = newVal
  },
  { immediate: true }
)

onBeforeMount(() => {
  loadTaggedItem()
  document.addEventListener('pinboard:insert', updateState)
})

onBeforeUnmount(() => {
  document.removeEventListener('pinboard:insert', updateState)
})

function updateState({ detail }) {
  if (detail.type === CONTROLLED_VOCABULARY_TERM) {
    keywordId.value = getDefaultConfidence()
    getTotalUsed()
    loadTaggedItem()
  }
}

function getDefaultConfidence() {
  const defaultConfidence = getDefaultConfidenceElement()
  return defaultConfidence?.getAttribute('data-pinboard-object-id')
}

function getDefaultConfidenceElement() {
  return document.querySelector(
    '[data-pinboard-section="ConfidenceLevels"] [data-insert="true"]'
  )
}

function loadTaggedItem() {
  if (!keywordId.value) return

  const params = {
    global_id: props.globalId,
    confidence_level_id: keywordId.value
  }

  isLoading.value = true

  Confidence.exists(params)
    .then(({ body }) => {
      if (body) {
        confidenceItem.value = body
      }
    })
    .finally(() => {
      isLoading.value = false
    })
}

function getTotalUsed() {
  if (!keywordId.value) return

  const params = {
    confidence_level_id: [keywordId],
    per: 1
  }

  Confidence.where(params).then((response) => {
    totalUsed.value = getPagination(response)
  })
}

function createConfidence() {
  const payload = {
    confidence: {
      confidence_level_id: keywordId.value,
      annotated_global_entity: props.globalId
    }
  }

  Confidence.create(payload).then(({ body }) => {
    confidenceItem.value = body
    totalUsed.value++
    TW.workbench.alert.create(
      'Confidence item was successfully created.',
      'notice'
    )
  })
}

function deleteConfidence() {
  Confidence.destroy(confidenceItem.value.id).then(() => {
    confidenceItem.value = null
    totalUsed.value--
    TW.workbench.alert.create(
      'Confidence item was successfully destroyed.',
      'notice'
    )
  })
}
</script>
