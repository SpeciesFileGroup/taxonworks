<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <SmartSelector
      :model="model"
      :klass="klass"
      :label="label"
      :pin-section="pinSection"
      :pin-type="pinType"
      @selected="setRecord"
    />
    <SmartSelectorItem
      v-if="record"
      class="separate-top"
      :item="record"
      :label="label"
      @unset="unsetRecord"
    />
  </FacetContainer>
</template>

<script setup>
import { ref, watch, onBeforeMount } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  title: {
    type: String,
    required: true
  },

  param: {
    type: String,
    required: true
  },

  model: {
    type: String,
    required: true
  },

  klass: {
    type: String,
    required: true
  },

  service: {
    type: Object,
    required: true
  },

  label: {
    type: String,
    default: 'object_tag'
  },

  pinSection: {
    type: String,
    default: undefined
  },

  pinType: {
    type: String,
    default: undefined
  }
})

const params = defineModel({
  type: Object,
  required: true
})

const record = ref(null)

watch(
  () => params.value[props.param],
  (newVal) => {
    if (!newVal) {
      record.value = null
    }
  }
)

onBeforeMount(() => {
  const id = params.value[props.param]

  if (id) {
    props.service.find(id).then(({ body }) => {
      record.value = body
    })
  }
})

function setRecord(item) {
  record.value = item
  params.value[props.param] = item.id
}

function unsetRecord() {
  record.value = null
  params.value[props.param] = undefined
}
</script>
