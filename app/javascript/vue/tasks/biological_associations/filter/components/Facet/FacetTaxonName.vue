<template>
  <div>
    <h3>Taxon name</h3>
    <div class="field">
      <smart-selector
        model="taxon_names"
        @selected="taxon = $event"
      />
      <smart-selector-item
        :item="taxon"
        label="object_tag"
        @unset="taxon = undefined"
      />
    </div>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'
import { ref, computed, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const taxon = ref(undefined)
const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  taxon,
  newVal => {
    params.value = newVal
      ? newVal.id
      : undefined
  }
)

watch(
  () => params.value,
  newVal => {
    if (!newVal) {
      taxon.value = undefined
    }
  }
)

const { taxon_name_id } = URLParamsToJSON(location.href)

if (taxon_name_id) {
  TaxonName.find(taxon_name_id).then(({ body }) => {
    taxon.value = body
  })
}

</script>
