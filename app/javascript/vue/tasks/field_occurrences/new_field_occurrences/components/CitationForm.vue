<template>
  <BlockLayout>
    <template #header>
      <h3>Citations</h3>
    </template>
    <template #body>
      <FormCitation
        v-model="store.citation"
        :submit-button="{
          color: 'primary',
          label: store.citation.id ? 'Update' : 'Add'
        }"
        @submit="addCitation"
      />
      <FormCitationList
        :list="store.citations.filter((item) => !item._destroy)"
        v-model:lock="settings.locked.citations"
        label="label"
        @edit="(item) => (store.citation = { ...item })"
        @delete="removeItem"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import FormCitationList from '@/components/Form/FormCitation/FormCitationList.vue'
import useCitationStore from '../store/citations.js'
import useSettingStore from '../store/settings.js'
import { addToArray, removeFromArray } from '@/helpers'

const store = useCitationStore()
const settings = useSettingStore()

function addCitation(citation) {
  addToArray(
    store.citations,
    {
      ...citation,
      isUnsaved: true
    },
    { property: 'uuid' }
  )

  store.newCitation()
}

function removeItem(citation) {
  if (citation.id) {
    citation._destroy = true
  } else {
    removeFromArray(store.citations, citation, 'uuid')
  }
}
</script>
