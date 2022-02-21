<template>
  <div>
    <h3>Otu</h3>
    <div class="field">
      <smart-selector
        model="otus"
        klass="otus"
        :target="target"
        @selected="addToArray(otusStore, $event)"
      />
    </div>
    <display-list
      :list="otusStore"
      label="object_label"
      :delete-warning="false"
      @delete="removeFromArray(otusStore, $event)"
    />
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Otu } from 'routes/endpoints'
import { addToArray, removeFromArray } from 'helpers/arrays'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  },

  target: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const otusStore = ref([])

const otuIds = computed({
  get: () => props.modelValue,
  set: value => { emit('update:modelValue', value) }
})

watch(
  () => props.modelValue,
  (newVal, oldVal) => {
    if (!newVal.length && oldVal.length) {
      otusStore.value = []
    }
  }
)

watch(
  otusStore,
  newVal => {
    otuIds.value = newVal.map(otu => otu.id)
  },
  { deep: true }
)

const { otu_id = [] } = URLParamsToJSON(location.href)

Promise
  .all(otu_id.map(id => Otu.find(id)))
  .then(responses => {
    otusStore.value = responses.map(r => r.body)
  })

</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
