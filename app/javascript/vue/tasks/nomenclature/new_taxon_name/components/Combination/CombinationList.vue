<template>
  <div class="margin-medium-top">
    <h3 v-if="isPlant && !currentCombination">
      Select current combination
    </h3>
    <ul class="table-entrys-list">
      <li
        v-for="combination in list"
        :key="combination.id"
        class="list-complete-item flex-separate middle">
        <label>
          <input
            v-if="isPlant"
            type="radio"
            :checked="currentCombination && combination.id === currentCombination.subject_taxon_name_id"
            name="current-combination"
            @click="saveRelationship(combination.id)">
          {{ combination.object_label }}
        </label>
        <div class="horizontal-left-content middle">
          <radial-annotator :global-id="combination.global_id" />
          <v-btn
            class="circle-button"
            circle
            color="update"
            @click="emit('edit', combination)">
            <v-icon
              x-small
              name="pencil"
            />
          </v-btn>
          <v-btn
            class="circle-button"
            circle
            color="destroy"
            @click="deleteCombination(combination)">
            <v-icon
              x-small
              name="trash"
            />
          </v-btn>
        </div>
      </li>
    </ul>
    <div v-if="currentCombination">
      <h3>Current combination</h3>
      <div class="flex-separate middle">
        <span v-html="currentCombination.subject_object_tag"/>
        <v-btn
          class="circle-button"
          circle
          color="destroy"
          @click="destroyRelationship">
          <v-icon
            x-small
            name="trash"
          />
        </v-btn>
      </div>
    </div>
    <v-confirmation ref="confirmationModal"/>
  </div>
</template>
<script setup>

import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { TaxonNameRelationship } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters.js'
import { ActionNames } from '../../store/actions/actions.js'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VConfirmation from 'components/ConfirmationModal.vue'
import {
  TAXON_RELATIONSHIP_CURRENT_COMBINATION,
  NOMENCLATURE_CODE_BOTANY
} from 'constants/index.js'

const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})
const emit = defineEmits(['edit', 'delete'])

const store = useStore()
const currentCombination = ref(undefined)
const confirmationModal = ref(null)

const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const isPlant = computed(() => taxon.value.nomenclatural_code === NOMENCLATURE_CODE_BOTANY)

const saveRelationship = combinationId => {
  const relationship = {
    subject_taxon_name_id: combinationId,
    object_taxon_name_id: taxon.value.id,
    type: TAXON_RELATIONSHIP_CURRENT_COMBINATION
  }

  const saveRequest = currentCombination.value
    ? TaxonNameRelationship.update(currentCombination.value.id, { taxon_name_relationship: relationship })
    : TaxonNameRelationship.create({ taxon_name_relationship: relationship })

  saveRequest.then(({ body }) => {
    currentCombination.value = body
    store.dispatch(ActionNames.UpdateTaxonName, taxon.value)
  })
}

const destroyRelationship = () =>
  TaxonNameRelationship.destroy(currentCombination.value.id).then(_ => {
    currentCombination.value = undefined
    TW.workbench.alert.create('Current combination was successfully removed.', 'notice')
    store.dispatch(ActionNames.UpdateTaxonName, taxon.value)
  })


TaxonNameRelationship.where({
  object_taxon_name_id: taxon.value.id,
  type: TAXON_RELATIONSHIP_CURRENT_COMBINATION
}).then(({ body }) => {
  currentCombination.value = body.find(relationship => relationship.type === TAXON_RELATIONSHIP_CURRENT_COMBINATION)
})

const deleteCombination = async combination => {
  if (combination.id === currentCombination.value?.subject_taxon_name_id) {
    const ok = await confirmationModal.value.show({
      title: 'Destroy combination',
      message: 'This will destroy the current combination relationship too. Are you sure you want to proceed?.',
      typeButton: 'delete'
    })

    if (ok) {
      destroyRelationship().then(_ => {
        emit('delete', combination)
      })
    }
  } else {
    emit('delete', combination)
  }
}

</script>
