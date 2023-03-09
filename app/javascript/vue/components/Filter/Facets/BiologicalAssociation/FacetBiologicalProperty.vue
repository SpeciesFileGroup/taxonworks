<template>
  <FacetContainer>
    <h3>Biological property</h3>
    <div class="field">
      <VAutocomplete
        url="/controlled_vocabulary_terms/autocomplete"
        param="term"
        :add-params="{ type: ['BiologicalProperty'] }"
        label="label_html"
        clear-after
        @getItem="({ id }) => addBiologicalProperty(id)"
      />
      <table
        v-if="biologicalProperties.length"
        class="vue-table"
      >
        <thead>
          <tr>
            <th>Property</th>
            <th />
            <th />
          </tr>
        </thead>
        <transition-group
          name="list-complete"
          tag="tbody"
        >
          <template
            v-for="item in biologicalProperties"
            :key="item.id"
          >
            <RowItem
              class="list-complete-item"
              :item="item"
              label="object_tag"
              :options="{
                subject: true,
                object: false
              }"
              v-model="item.isSubject"
              @remove="removeBiologicalProperty"
            />
          </template>
        </transition-group>
      </table>
    </div>
  </FacetContainer>
</template>

<script setup>
import RowItem from 'components/Filter/Facets/shared/RowItem.vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import VAutocomplete from 'components/ui/Autocomplete.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { ref, computed, watch } from 'vue'
import { removeFromArray } from 'helpers/arrays'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const biologicalProperties = ref([])
const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

watch(
  [
    () => params.value.object_biological_property_id,
    () => params.value.subject_biological_property_id
  ],
  () => {
    if (
      !params.value.object_biological_property_id?.length &&
      !params.value.subject_biological_property_id?.length &&
      biologicalProperties.value.length
    ) {
      biologicalProperties.value = []
    }
  }
)

watch(
  biologicalProperties,
  (newVal) => {
    params.value.object_biological_property_id = newVal
      .filter((item) => !item.isSubject)
      .map((item) => item.id)
    params.value.subject_biological_property_id = newVal
      .filter((item) => item.isSubject)
      .map((item) => item.id)
  },
  { deep: true }
)

function addBiologicalProperty(id, isSubject = false) {
  ControlledVocabularyTerm.find(id).then(({ body }) => {
    biologicalProperties.value.push({
      ...body,
      isSubject
    })
  })
}

function removeBiologicalProperty(biologicalRelationship) {
  removeFromArray(biologicalProperties.value, biologicalRelationship)
}

const {
  subject_biological_property_id: subjectIds = [],
  object_biological_property_id: objectIds = []
} = URLParamsToJSON(location.href)

subjectIds.forEach((id) => {
  addBiologicalProperty(id, true)
})

objectIds.forEach((id) => {
  addBiologicalProperty(id, false)
})
</script>
