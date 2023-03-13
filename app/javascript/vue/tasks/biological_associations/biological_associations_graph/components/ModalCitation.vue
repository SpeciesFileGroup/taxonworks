<template>
  <VModal :container-style="{ width: '800px' }">
    <template #header>
      <h3>Citations</h3>
    </template>
    <template #body>
      Add to:
      <ul class="no_bullets">
        <li
          v-for="({ label, item }, index) in objectItems"
          :key="index"
        >
          <label>
            <input
              type="checkbox"
              :value="item"
              v-model="selectedItems"
            />
            {{ label }}
          </label>
        </li>
      </ul>
      <FormCitation
        class="margin-medium-top margin-medium-bottom"
        v-model="citation"
        :submit-button="{ color: 'primary', label: 'Add' }"
        @submit="
          ($event) =>
            emit('add:citation', { citationData: $event, items: selectedItems })
        "
      />
      <div
        v-for="{ label, item } in objectItems"
        :key="item.uuid"
      >
        <TableCitation
          :title="label"
          :citations="item.citations"
          @remove="
            ($event) => emit('remove:citation', { citation: $event, obj: item })
          "
        />
      </div>
    </template>
  </VModal>
</template>

<script setup>
import VModal from 'components/ui/Modal'
import FormCitation from 'components/Form/FormCitation.vue'
import TableCitation from './TableCitation.vue'
import { BIOLOGICAL_ASSOCIATIONS_GRAPH } from 'constants/index.js'
import { ref, computed } from 'vue'

const props = defineProps({
  citations: {
    type: Array,
    default: () => []
  },

  items: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['add:citation', 'remove:citation'])
const selectedItems = ref([...props.items])

const objectItems = computed(() => {
  return props.items.map((item) => {
    const label =
      item.objectType === BIOLOGICAL_ASSOCIATIONS_GRAPH
        ? item.label || 'Graph'
        : item.subject.name +
          ' => ' +
          item.biologicalRelationship.name +
          ' => ' +
          item.object.name

    return {
      item,
      label
    }
  })
})

const citation = ref({})
</script>
