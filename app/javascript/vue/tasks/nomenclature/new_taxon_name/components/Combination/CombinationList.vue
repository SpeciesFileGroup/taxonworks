<template>
  <div class="margin-medium-top">
    <h3 v-if="isPlant && !currentCombination">
      Preferred name (optional)
    </h3>
    <h3 v-else>
      Combinations
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
const currentCombination = computed(() => store.getters[GetterNames.GetTaxonRelationshipList].find(item => item.type === TAXON_RELATIONSHIP_CURRENT_COMBINATION))
const confirmationModal = ref(null)

const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const isPlant = computed(() => taxon.value.nomenclatural_code === NOMENCLATURE_CODE_BOTANY)

const saveRelationship = combinationId => {
  const relationship = {
    id: currentCombination.value?.id,
    subject_taxon_name_id: combinationId,
    object_taxon_name_id: taxon.value.id,
    type: TAXON_RELATIONSHIP_CURRENT_COMBINATION
  }

  const saveRequest = currentCombination.value
    ? store.dispatch(ActionNames.UpdateTaxonRelationship, relationship)
    : store.dispatch(ActionNames.AddTaxonRelationship, relationship)

  saveRequest.then(({ body }) => {
    store.dispatch(ActionNames.UpdateTaxonName, taxon.value)
  })
}

const destroyRelationship = async () => {
  const ok = await confirmationModal.value.show({
    title: 'Destroy relationship',
    message: 'Are you sure you want to delete the current combination relationship?',
    typeButton: 'delete'
  })

  if (ok) {
    store.dispatch(ActionNames.RemoveTaxonRelationship, currentCombination.value).then(_ => {
      store.dispatch(ActionNames.UpdateTaxonName, taxon.value)
    })
  }
}

const deleteCombination = async combination => {
  const isCurrent = combination.id === currentCombination.value?.subject_taxon_name_id
  const ok = await confirmationModal.value.show({
    title: 'Destroy combination',
    message: isCurrent
      ? `Are you sure you want to delete ${combination.object_label}. This will destroy the current combination relationship too.`
      : `Are you sure you want to delete ${combination.object_label}`,
    typeButton: 'delete'
  })

  if (ok) {
    store.dispatch(ActionNames.RemoveTaxonRelationship, currentCombination.value).then(_ => {
      store.dispatch(ActionNames.UpdateTaxonName, taxon.value)
      emit('delete', combination)
    })
  }
}

</script>
