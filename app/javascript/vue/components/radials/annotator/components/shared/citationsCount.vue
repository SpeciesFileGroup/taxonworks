<template>
  <span>
    <div
      v-if="citations.length"
      class="citation-count"
      @click.prevent="() => (isModalVisible = true)"
    >
      <span class="circle-button btn-citation button-default">
        <span class="circle-count button-data middle"
          >{{ citations.length }}
        </span>
      </span>
    </div>
    <VModal
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Citations</h3>
      </template>
      <template #body>
        <display-list
          :list="citations"
          :validations="true"
          :label="['citation_source_body']"
          :edit="false"
          @delete="removeCitation"
        >
          <template #options="slotProps">
            <div>
              <a
                :title="slotProps.item.source.object_tag"
                class="button-default circle-button btn-citation"
                :href="`/tasks/nomenclature/by_source?source_id=${slotProps.item.source_id}`"
                target="blank"
              />
            </div>
          </template>
        </display-list>
      </template>
    </VModal>
  </span>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { Citation } from '@/routes/endpoints'
import { CITATION } from '@/constants'
import { removeFromArray } from '@/helpers'
import DisplayList from '@/components/displayList'
import VModal from '@/components/ui/Modal.vue'

const props = defineProps({
  object: {
    type: Object,
    required: true
  }
})

const isModalVisible = ref(false)
const citations = ref([])

onMounted(() => {
  loadCitations()
  document.addEventListener('radial:post', refreshCitations)
  document.addEventListener('radial:patch', refreshCitations)
  document.addEventListener('radial:delete', refreshCitations)
})

onBeforeUnmount(() => {
  document.removeEventListener('radial:post', refreshCitations)
  document.removeEventListener('radial:patch', refreshCitations)
  document.removeEventListener('radial:delete', refreshCitations)
})

function removeCitation(cite) {
  Citation.destroy(cite.id).then((_) => {
    removeFromArray(citations.value, cite)
  })
}

function loadCitations() {
  Citation.where({
    citation_object_id: props.object.id,
    citation_object_type: props.object.base_class,
    extend: ['source']
  }).then(({ body }) => {
    citations.value = body
  })
}

function refreshCitations(event) {
  if (event) {
    if (
      event.detail.object.hasOwnProperty('citation') ||
      (event.detail.object.hasOwnProperty('base_class') &&
        event.detail.object.base_class === CITATION)
    ) {
      loadCitations()
    }
  }
}
</script>

<style lang="scss">
.citation-count {
  position: relative;
}
.citation-count-text {
  position: relative;
  font-size: 100%;
  justify-content: center;
}
.circle-count {
  right: -5px;
  bottom: -6px;
  justify-content: center;
  position: absolute;
  border-radius: 50%;
  display: flex;
  width: 12px;
  height: 12px;
  min-width: 12px;
  min-height: 12px;
  font-size: 8px;
  box-shadow: 0px 1px 2px 0px #ebebeb;
  margin: 5px;
  cursor: pointer;
}
</style>
