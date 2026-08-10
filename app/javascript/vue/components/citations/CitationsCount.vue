<template>
  <div class="horizontal-left-content">
    <VBtn
      v-if="citations?.length"
      icon
      color="primary"
      variant="tonal"
      class="citation-count"
      title="Citations"
      @click.prevent="setModalView(true)"
    >
      <IconQuote class="w-4 h-4" />
      <span
        class="circle-count button-data middle"
        v-text="citations.length"
      />
    </VBtn>
    <VModal
      v-if="showCitations"
      @close="setModalView(false)"
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
          @delete="(item) => emit('delete', item)"
        >
          <template #options="{ item }">
            <div>
              <VBtn
                icon
                color="primary"
                variant="tonal"
                :title="item.source.object_tag"
                :href="`${RouteNames.NomenclatureBySource}?source_id=${item.source.id}`"
                target="blank"
              >
                <IconQuote class="w-4 h-4" />
              </VBtn>
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
import IconQuote from '@/components/Icon/IconQuote.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

defineProps({
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

<style scoped>
.citation-count {
  position: relative;
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
  box-shadow: var(--panel-shadow);
  margin: 5px;
  cursor: pointer;
}
</style>
