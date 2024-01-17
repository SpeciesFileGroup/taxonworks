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
          label: 'Add'
        }" 
        @submit="addCitation"
      />
      <DisplayList
        :list="store.citations"
        label="label"
        @delete-index="(index) => store.citations.splice(index, 1)"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue';
import FormCitation from '@/components/Form/FormCitation.vue';
import DisplayList from '@/components/displayList.vue'
import useCitationStore from '../store/citations.js'

const store = useCitationStore()

function addCitation(citation) {
  store.citations.push({
    ...citation,
    isUnsaved: true
  })

  store.newCitation()
}
</script>