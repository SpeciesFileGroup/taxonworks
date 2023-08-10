<template>
  <block-layout
    anchor="family-group-name-form"
    :spinner="!taxon.id"
  >
    <template #header>
      <h3>Subsequent name forms</h3>
    </template>
    <template #body>
      <EditTaxonName
        v-if="relationship"
        :relationship="relationship"
        @reset="resetForm"
      />
      <div v-else>
        <div class="horizontal-left-content gap-small margin-medium-bottom">
          <input
            placeholder="Type a name..."
            type="text"
            v-model="name"
          />
          <VBtn
            color="primary"
            medium
            @click="() => (name = taxon.name)"
          >
            Clone from current
          </VBtn>
        </div>
        <FormCitation v-model="citation" />
        <div class="horizontal-left-content gap-small margin-medium-top">
          <VBtn
            color="create"
            medium
            :disabled="!name.length"
            @click="() => addRelationship(name)"
          >
            Create
          </VBtn>
          <VBtn
            color="primary"
            medium
            @click="resetForm"
          >
            New
          </VBtn>
        </div>
      </div>

      <DisplayList
        edit
        annotator
        label="object_tag"
        :list="getRelationshipsCreated"
        @edit="(item) => (relationship = item)"
        @delete="
          (item) => store.dispatch(ActionNames.RemoveTaxonRelationship, item)
        "
      />
    </template>
  </block-layout>
</template>

<script setup>
import { TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM } from '../../const/relationshipTypes.js'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import VBtn from '@/components/ui/VBtn/index.vue'
import DisplayList from '@/components/displayList.vue'
import BlockLayout from '@/components/layout/BlockLayout'
import EditTaxonName from './EditTaxonName'
import FormCitation from '@/components/Form/FormCitation.vue'

const store = useStore()

const name = ref('')
const relationship = ref()
const citation = ref({})

const taxon = computed(() => store.getters[GetterNames.GetTaxon])

const getRelationshipsCreated = computed(() =>
  store.getters[GetterNames.GetTaxonRelationshipList].filter(
    (item) => item.type === TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM
  )
)

function addRelationship(name) {
  store
    .dispatch(ActionNames.AddSubsequentNameForm, {
      name,
      citation: citation.value
    })
    .then((response) => {
      resetForm()

      TW.workbench.alert.create(
        'Taxon name relationship was successfully saved.',
        'notice'
      )
    })
}

function resetForm() {
  name.value = ''
  citation.value = {}
  relationship.value = null
}
</script>
