<template>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Create taxon name</h3>
    </template>
    <template #body>
      <h4>Name</h4>
      <span v-html="item.label_html" />
      <h4>Parents</h4>
      <ul class="tree">
        <li v-for="item in parentList">
          <label>
            <input
              v-if="!item._disabled"
              type="checkbox"
              :disabled="item._disabled"
              v-model="selectedParents"
              :value="item"
            />
            <span v-html="item.cached_name || item.name" />
          </label>
        </li>
      </ul>
      <VBtn
        class="margin-medium-top"
        color="create"
        @click="createTaxonNames"
        >Create
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref, watch } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const item = ref(null)
const isModalVisible = ref(false)
const selectedParents = ref([])
const parentList = ref([])

function setItem(value) {
  item.value = value
  isModalVisible.value = true
}

function createTaxonNames() {
  const classification = item.value.expansion.simple_taxon_name_classification
  const selectedNames = selectedParents.value.map((item) => item.name)
  const payload = classification.filter((item) =>
    selectedNames.includes(item.name)
  )

  console.log(payload)
}

watch(item, (newVal) => {
  if (!newVal?.expansion?.simple_taxon_name_classification) return []

  let TWParentFound = false
  const parents = []
  const classification = [...newVal.expansion.simple_taxon_name_classification]

  classification.reverse()
  classification.forEach((item) => {
    if (item.id) {
      TWParentFound = true
    }

    parents.unshift({
      ...item,
      _disabled: TWParentFound
    })
  })

  parentList.value = parents
  selectedParents.value = parents.filter((item) => !item._disabled)
})

defineExpose({
  setItem
})
</script>
