<template>
  <FacetContainer>
    <h3>Otu</h3>
    <div class="field">
      <SmartSelector
        model="otus"
        klass="otus"
        :target="target"
        @selected="addToArray(otusStore, $event)"
      />
    </div>
    <DisplayList
      v-if="otusStore.length"
      :list="otusStore"
      label="object_tag"
      :delete-warning="false"
      soft-delete
      @delete="removeFromArray(otusStore, $event)"
    />
    <OtuCoordinate v-if="coordinate" />
    <VIncludes
      v-if="includes.length"
      :includes="includes"
      v-model="params"
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Otu } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import VIncludes from './components/Includes.vue'
import OtuCoordinate from './components/OtuCoordinate.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  target: {
    type: String,
    required: true
  },

  includes: {
    type: Array,
    default: () => []
  },

  coordinate: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])
const otusStore = ref([])

const params = computed({
  get: () => props.modelValue,
  set: (value) => {
    emit('update:modelValue', value)
  }
})

watch(
  () => props.modelValue.otu_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      otusStore.value = []
    }
  }
)

watch(
  otusStore,
  (newVal) => {
    params.value.otu_id = newVal.map((otu) => otu.id)
  },
  { deep: true }
)

const otuIds = params.value.otu_id || []

if (otuIds.length) {
  Otu.all({ otu_id: otuIds }).then(({ body }) => {
    otusStore.value = body
  })
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
