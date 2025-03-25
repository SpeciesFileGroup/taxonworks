<template>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3 v-html="item.label_html" />
    </template>
    <template #body>
      <ul class="tree">
        <li v-for="taxon in item.expansion.simple_taxon_name_classification">
          <span v-html="taxon.cached_name || taxon.name" />
        </li>
      </ul>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'

const item = ref(null)
const isModalVisible = ref(false)

function setItem(value) {
  item.value = value
  isModalVisible.value = true
}

defineExpose({
  setItem
})
</script>
