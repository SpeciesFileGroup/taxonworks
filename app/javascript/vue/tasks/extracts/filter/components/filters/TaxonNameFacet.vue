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
      <div class="field separate-top">
        <ul class="no_bullets">
          <li
            v-for="item in validityOptions"
            :key="item.value"
          >
            <label>
              <input
                type="radio"
                :value="item.value"
                name="taxon-validity"
                v-model="params.validity">
              {{ item.label }}
            </label>
          </li>
        </ul>
      </div>
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
const validityOptions = [
  {
    label: 'Both valid/invalid',
    value: undefined
  },
  {
    label: 'Valid only',
    value: true
  },
  {
    label: 'Invalid only',
    value: false
  }
]

const taxon = ref(undefined)
const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  taxon,
  newVal => {
    params.value.ancestor_id = newVal
      ? newVal.id
      : undefined
  }
)

watch(() => params.value.ancestor_id, newVal => {
  if (!newVal) {
    taxon.value = undefined
  }
})

const {
  ancestor_id,
  validity
} = URLParamsToJSON(location.href)

if (ancestor_id) {
  TaxonName.find(ancestor_id).then(({ body }) => {
    taxon.value = body
  })
}

params.value.validity = validity

</script>
