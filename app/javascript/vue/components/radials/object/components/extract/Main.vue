<template>
  <div>
    <SmartSelector
      model="extracts"
      klass="CollectionObject"
    />
    <DisplayList
      :list="list"
      label="object_tag"
    />
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import { Extract } from '@/routes/endpoints'
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

function createExtract(item) {
  Extract.create({
    extract: {}
  })
}
</script>
