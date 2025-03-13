<template>
  <block-layout :warning="!determinationStore.determinations.length">
    <template #header>
      <h3>Determinations</h3>
    </template>
    <template #body>
      <div id="taxon-determination-digitize">
        <TaxonDeterminationForm
          ref="determinationRef"
          v-model:lock-determiner="locked.taxon_determination.roles_attributes"
          v-model:lock-otu="locked.taxon_determination.otu_id"
          v-model:lock-date="locked.taxon_determination.dates"
          @on-add="determinationStore.add"
        />
        <TaxonDeterminationList
          v-model="determinationStore.determinations"
          v-model:lock="locked.taxonDeterminations"
          @edit="editTaxonDetermination"
          @delete="determinationStore.remove"
        />
      </div>
    </template>
  </block-layout>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed, onBeforeMount, useTemplateRef } from 'vue'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { useTaxonDeterminationStore } from '../../store/pinia'
import { randomUUID } from '@/helpers'
import { Otu } from '@/routes/endpoints'
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import TaxonDeterminationList from '@/components/TaxonDetermination/TaxonDeterminationList.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const store = useStore()
const determinationStore = useTaxonDeterminationStore()
const taxonDeterminationRef = useTemplateRef('determinationRef')

const locked = computed({
  get() {
    return store.getters[GetterNames.GetLocked]
  },
  set(value) {
    store.commit(MutationNames.SetLocked, value)
  }
})

function editTaxonDetermination(item) {
  taxonDeterminationRef.value.setDetermination({
    id: item.id,
    uuid: item.uuid,
    global_id: item.global_id,
    otu_id: item.otu_id,
    day_made: item.day_made,
    month_made: item.month_made,
    year_made: item.year_made,
    position: item.position,
    roles_attributes: item?.determiner_roles || item.roles_attributes || []
  })
}

async function makeDeterminationFromParameters() {
  const urlParams = new URLSearchParams(window.location.search)
  const otuId = urlParams.get('otu_id')
  const taxonId = urlParams.get('taxon_name_id')
  const coId = urlParams.get('collection_object_id')

  if ((!otuId && !taxonId) || coId) return

  console.log(coId)

  const params = {
    otu_id: otuId,
    taxon_name_id: taxonId
  }

  const otus = (await Otu.where(params)).body
  let otu

  if (otus.length) {
    otu = otus[0]
  } else if (taxonId) {
    otu = (await Otu.create({ otu: { taxon_name_id: taxonId } })).body
  }

  if (otu) {
    determinationStore.add({
      uuid: randomUUID(),
      object_tag: otu.object_tag,
      otu_id: otu.id,
      roles_attributes: [],
      isUnsaved: true
    })
  }
}

onBeforeMount(makeDeterminationFromParameters)
</script>

<style lang="scss">
#taxon-determination-digitize {
  label {
    display: block;
  }
  li label {
    display: inline;
  }
  .role-picker {
    .vue-autocomplete-input {
      max-width: 150px;
    }
  }
}
</style>
