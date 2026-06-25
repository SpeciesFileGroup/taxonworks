<template>
  <div v-if="keywordId && !isLoading">
    <VTooltip>
      <template #content>
        <span>
          {{ tagItem ? 'Remove' : 'Create' }} tag:
          {{ getDefaultKeywordElement().firstChild.firstChild.textContent }}.
          <br />
          {{ showCount ? `Used already on ${totalUsed} objects.` : '' }}
        </span>
      </template>

      <VBtn
        icon
        variant="tonal"
        :color="tagItem ? 'destroy' : 'create'"
        @click="
          () => {
            tagItem ? deleteTag() : createTag()
          }
        "
      >
        <IconTagX
          v-if="tagItem"
          class="w-4 h-4"
        />
        <IconTagPlus
          v-else
          class="w-4 h-4"
        />
      </VBtn>
    </VTooltip>
  </div>
  <VBtn
    v-else
    variant="tonal"
    icon
    color="disabled"
    title="Select a default keyword from pinboard."
  >
    <IconTag class="w-4 h-4" />
  </VBtn>
</template>

<script setup>
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'
import { Tag } from '@/routes/endpoints'
import { ref, watch, onBeforeMount, onBeforeUnmount } from 'vue'
import { getPagination } from '@/helpers'
import { CONTROLLED_VOCABULARY_TERM } from '@/constants'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTagPlus from '@/components/Icon/IconTagPlus.vue'
import IconTagX from '@/components/Icon/IconTagX.vue'
import IconTag from '@/components/Icon/IconTag.vue'

const props = defineProps({
  globalId: {
    type: String,
    required: true
  },

  showCount: {
    type: Boolean,
    default: false
  },

  count: {
    type: [Number, String],
    default: undefined
  }
})

const tagItem = ref(null)
const keywordId = ref(getDefaultKeyword())
const totalUsed = ref(0)
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

function updateState(event) {
  const details = event.detail

  if (details.type === CONTROLLED_VOCABULARY_TERM) {
    keywordId.value = getDefaultKeyword()

    if (props.showCount) {
      getTotalObjectsTagged()
    }

    loadTaggedItem()
  }
}

function getDefaultKeyword() {
  const element = getDefaultKeywordElement()

  return element?.getAttribute('data-pinboard-object-id')
}

function getDefaultKeywordElement() {
  return document.querySelector(
    '[data-pinboard-section="Keywords"] [data-insert="true"]'
  )
}

function loadTaggedItem() {
  if (!keywordId.value) return

  const payload = {
    global_id: props.globalId,
    keyword_id: keywordId.value
  }

  isLoading.value = true

  Tag.exists(payload)
    .then(({ body }) => {
      if (body) {
        tagItem.value = body
      }
    })
    .finally(() => {
      isLoading.value = false
    })
}

function getTotalObjectsTagged() {
  if (!keywordId.value) return

  const payload = {
    keyword_id: [keywordId],
    per: 1
  }

  Tag.where(payload).then((response) => {
    totalUsed.value = getPagination(response).total
  })
}

function createTag() {
  const tag = {
    keyword_id: keywordId.value,
    annotated_global_entity: props.globalId
  }

  Tag.create({ tag }).then(({ body }) => {
    tagItem.value = body
    totalUsed.value++
    TW.workbench.alert.create('Tag item was successfully created.', 'notice')
  })
}

function deleteTag() {
  Tag.destroy(tagItem.value.id).then(() => {
    tagItem.value = null
    totalUsed.value--
    TW.workbench.alert.create('Tag item was successfully destroyed.', 'notice')
  })
}
</script>
