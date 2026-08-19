<template>
  <CustomAttributes
    v-if="projectPreferences"
    :key="typeMaterial.uuid"
    :object-id="typeMaterial.id"
    :object-type="TYPE_MATERIAL"
    :model="TYPE_MATERIAL"
    :model-preferences="projectPreferences.model_predicate_sets?.TypeMaterial"
    :pending-attributes="typeMaterial.data_attributes_attributes"
    @on-update="setAttributes"
  />
</template>

<script setup>
import CustomAttributes from '@/components/custom_attributes/predicates/predicates'
import { TYPE_MATERIAL } from '@/constants'
import { GetterNames } from '../../store/getters/getters.js'
import { computed } from 'vue'
import { useStore } from 'vuex'

const store = useStore()

const typeMaterial = computed(() => store.getters[GetterNames.GetTypeMaterial])

const projectPreferences = computed(
  () => store.getters[GetterNames.GetProjectPreferences]
)

/*
  The panel edits a draft (`state.typeMaterial`), not a persisted record, so the
  attributes are kept in memory and sent as nested attributes by
  `store/actions/saveTypeMaterial.js`. Keying on `uuid` remounts the component
  whenever another draft is edited, which reloads/reseeds the rows: `objectId`
  alone can not do it, it stays `undefined` between unsaved drafts.
*/
function setAttributes(dataAttributes) {
  typeMaterial.value.data_attributes_attributes = dataAttributes
  typeMaterial.value.isUnsaved = true
}
</script>
