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
        @update:name="updateName"
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
        <FormCitation
          :original="false"
          v-model="citation"
        />
      </div>
      <div class="horizontal-left-content gap-small margin-medium-top">
        <VBtn
          v-if="!relationship"
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
      <DisplayList
        edit
        annotator
        label="label"
        :list="getRelationshipsCreated"
        @edit="(item) => (relationship = item)"
        @delete="removeTaxonName"
      />
    </template>
  </block-layout>
</template>

<script setup>
import { TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM } from '../../const/relationshipTypes.js'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../../store/actions/actions'
import { MutationNames } from '../../store/mutations/mutations.js'
import { GetterNames } from '../../store/getters/getters'
import { TaxonName } from '@/routes/endpoints'
import { makeGlobalId } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import DisplayList from '@/components/displayList.vue'
import BlockLayout from '@/components/layout/BlockLayout'
import EditTaxonName from './EditTaxonName'
import FormCitation from '@/components/Form/FormCitation.vue'
import { RouteNames } from '@/routes/routes.js'

const store = useStore()

const name = ref('')
const relationship = ref()
const citation = ref({})

const taxon = computed(() => store.getters[GetterNames.GetTaxon])

const getRelationshipsCreated = computed(() =>
  store.getters[GetterNames.GetTaxonRelationshipList]
    .filter((item) => item.type === TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM)
    .map((item) => ({
      ...item,
      label: `<a href="${RouteNames.NewTaxonName}?taxon_name_id=${item.subject_taxon_name_id}">${item.subject_object_tag}</a>`,
      global_id: makeGlobalId({
        type: 'Protonym',
        id: item.subject_taxon_name_id
      })
    }))
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
    .catch(() => {})
}

function removeTaxonName(item) {
  store.dispatch(ActionNames.RemoveTaxonRelationship, item).then((_) => {
    TaxonName.destroy(item.subject_taxon_name_id).then((_) => {
      TW.workbench.alert.create(
        'Taxon name was successfully destroyed.',
        'notice'
      )

      if (relationship.value?.id === item.id) {
        resetForm()
      }
    })
  })
}

function updateName(name) {
  const payload = {
    ...relationship.value,
    subject_object_tag: name
  }

  store.commit(MutationNames.AddTaxonRelationship, payload)
}

function resetForm() {
  name.value = ''
  citation.value = {}
  relationship.value = null
}
</script>
