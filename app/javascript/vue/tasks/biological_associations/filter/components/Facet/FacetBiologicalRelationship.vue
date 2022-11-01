<template>
  <div>
    <h3>Biological relationships</h3>
    <div class="field">
      <smart-selector
        model="biological_relationships"
        @selected="taxon = $event"
      />
      <DisplayList
        :item="taxon"
        label="object_tag"
        @unset="taxon = undefined"
      />
    </div>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { BiologicalRelationship } from 'routes/endpoints'
import { ref, computed, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const biologicalRelationships = ref([])
const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  params,
  newVal => {
    if (!newVal) {
      biologicalRelationships.value = []
    }
  }
)

function addBiologicalRelationship (item) {
  params.value.push(item.id)
  biologicalRelationships.value.push(item)
}

const { biological_relationship_id = [] } = URLParamsToJSON(location.href)

biological_relationship_id.forEach(id => {
  BiologicalRelationship.find(id).then(({ body }) => {
    addBiologicalRelationship(body)
  })
})

</script>
