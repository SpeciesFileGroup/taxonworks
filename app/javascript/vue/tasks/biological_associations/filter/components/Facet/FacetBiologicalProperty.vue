<template>
  <div>
    <h3>Biological property</h3>
    <div class="field">
      <SmartSelector
        model="controlled_vocabulary_terms"
        :autocomplete-params="{ type: ['BiologicalProperty'] }"
        @selected="addBiologicalProperty"
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
              @remove="removeBiologicalProperty(item)"
            />
          </template>
        </transition-group>
      </table>
    </div>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import RowItem from 'tasks/sources/filter/components/filters/shared/RowItem.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { ref, computed, watch } from 'vue'
import { removeFromArray } from 'helpers/arrays'

const props = defineProps({
  object: {
    type: Array,
    default: () => []
  },

  subject: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:object', 'update:subject'])

const biologicalProperties = ref([])
const objectIds = computed({
  get: () => props.object,
  set: value => emit('update:object', value)
})
const subjectIds = computed({
  get: () => props.object,
  set: value => emit('update:subject', value)
})

watch(
  [objectIds, subjectIds],
  () => {
    if (!props.object.length && !props.subject.length && biologicalProperties.value.length) {
      biologicalProperties.value = []
    }
  }
)

watch(
  biologicalProperties,
  newVal => {
    objectIds.value = newVal.filter(item => !item.isSubject).map(item => item.id)
    subjectIds.value = newVal.filter(item => item.isSubject).map(item => item.id)
  },
  { deep: true }
)

function addBiologicalProperty (item, isSubject = false) {
  biologicalProperties.value.push({
    ...item,
    isSubject
  })
}

function removeBiologicalProperty (biologicalRelationship) {
  removeFromArray(biologicalProperties.value, biologicalRelationship)
}

const {
  subject_biological_property_id = [],
  object_biological_property_id = []
} = URLParamsToJSON(location.href)

subject_biological_property_id.forEach(id => {
  ControlledVocabularyTerm.find(id).then(({ body }) => {
    addBiologicalProperty(body, true)
  })
})

object_biological_property_id.forEach(id => {
  ControlledVocabularyTerm.find(id).then(({ body }) => {
    addBiologicalProperty(body, false)
  })
})

</script>
