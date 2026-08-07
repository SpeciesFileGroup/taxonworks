<template>
  <div>
    <h3>Determinations</h3>
    <TaxonDeterminationForm
      create-form
      @on-add="addDetermination"
    />
    <DisplayList
      :list="list"
      :radial-object="true"
      set-key="otu_id"
      label="object_tag"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import DisplayList from '@/components/displayList.vue'
import { TaxonDetermination } from '@/routes/endpoints'
import { onBeforeMount } from 'vue'
import { useSlice } from '@/components/radials/composables'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

onBeforeMount(() => {
  TaxonDetermination.where({
    taxon_determination_object_id: [props.objectId],
    taxon_determination_object_type: props.objectType
  }).then(({ body }) => {
    list.value = body
  })
})

function addDetermination(taxonDetermination) {
  if (
    list.value.find(
      (determination) =>
        determination.otu_id === taxonDetermination.otu_id &&
        determination.year_made === taxonDetermination.year_made
    )
  ) {
    return
  }

  const payload = {
    taxon_determination: {
      ...taxonDetermination,
      taxon_determination_object_id: props.objectId,
      taxon_determination_object_type: props.objectType
    }
  }

  TaxonDetermination.create(payload)
    .then(({ body }) => {
      TW.workbench.alert.create(
        'Taxon determination was successfully created.',
        'notice'
      )
      addToList(body)
    })
    .catch(() => {})
}

function removeItem(item) {
  TaxonDetermination.destroy(item.id)
    .then(() => {
      removeFromList(item)
      TW.workbench.alert.create(
        'Taxon determination was successfully destroyed.',
        'notice'
      )
    })
    .catch(() => {})
}
</script>
