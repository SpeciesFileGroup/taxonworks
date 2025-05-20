<template>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Create new taxon name</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isSaving"
        legend="Creating..."
      />
      <b>Taxon names</b>
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
        medium
        :disabled="!namesCount"
        @click="createTaxonNames"
        >{{
          namesCount > 1 ? `Create ${namesCount} new names` : 'Create new name'
        }}
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '../VSpinner.vue'

const item = ref(null)
const isModalVisible = ref(false)
const isSaving = ref(false)
const selectedParents = ref([])
const parentList = ref([])

const emit = defineEmits(['create'])

function setItem(value) {
  item.value = value
  isModalVisible.value = true
}

const namesCount = computed(() => selectedParents.value.length)

function createTaxonNames() {
  const classification = item.value.expansion.simple_taxon_name_classification
  const selectedNames = selectedParents.value.map((item) => item.name)
  const payload = {
    classification: classification.filter((item) =>
      selectedNames.includes(item.name)
    )
  }

  isSaving.value = true

  TaxonName.classification(payload)
    .then(({ body }) => {
      emit('create', body)
    })
    .catch(() => {})
    .finally(() => {
      isSaving.value = false
    })
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
