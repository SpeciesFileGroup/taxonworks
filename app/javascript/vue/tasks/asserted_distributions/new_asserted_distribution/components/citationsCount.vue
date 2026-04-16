<template>
  <div class="horizontal-left-content">
    <div
      v-if="citations.length"
      class="citation-count"
      @click.prevent="setModalView(true)"
    >
      <span class="circle-button btn-citation button-default">
        <span class="circle-count button-data middle"
          >{{ citations.length }}
        </span>
      </span>
    </div>
    <VModal
      v-if="showCitations"
      @close="setModalView(false)"
    >
      <template #header>
        <h3>Citations a</h3>
      </template>
      <template #body>
        <display-list
          :list="citations"
          :validations="true"
          :label="['citation_source_body']"
          :edit="false"
          @delete="(item) => emit('delete', item)"
        >
          <template #options="{ item }">
            <div>
              <a
                :title="item.source.object_tag"
                class="button-default circle-button btn-citation"
                :href="`${RouteNames.NomenclatureBySource}?source_id=${item.source.id}`"
                target="blank"
              />
            </div>
          </template>
        </display-list>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { ref } from 'vue'
import DisplayList from '@/components/displayList'
import VModal from '@/components/ui/Modal'

const props = defineProps({
  citations: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['delete'])

const showCitations = ref(false)

function setModalView(value) {
  showCitations.value = value
}
</script>
