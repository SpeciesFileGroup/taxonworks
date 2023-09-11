<template>
  <FacetContainer>
    <h3>Import dataset</h3>
    <VAutocomplete
      :array-list="datasetList"
      placeholder="Search an import dataset..."
      label="description"
      clear-after
      @get-item="addDataset"
    />
    <DisplayList
      :list="datasets"
      label="description"
      :delete-warning="false"
      soft-delete
      @delete="(item) => removeFromArray(datasets, item)"
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import { ImportDataset } from '@/routes/endpoints'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import DisplayList from '@/components/displayList.vue'
import { removeFromArray } from '@/helpers/arrays'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  includes: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])
const datasets = ref([])
const datasetList = ref([])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

function addDataset(dataset) {
  datasets.value.push(dataset)
}

watch(
  datasets,
  (newVal) => {
    params.value.import_dataset_id = newVal.map((item) => item.id)
  },
  {
    deep: true
  }
)

watch(
  () => props.modelValue.import_dataset_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      datasets.value = []
    }
  }
)

onBeforeMount(() => {
  ImportDataset.all().then(({ body }) => {
    datasetList.value = body
  })

  const requests = (params.value.import_dataset_id || []).map((id) =>
    ImportDataset.find(id)
  )

  Promise.all(requests).then((responses) => {
    datasets.value = responses.map((r) => r.body)
  })
})
</script>
