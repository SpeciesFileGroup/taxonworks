<template>
  <div class="flex-col gap-medium">
    <a
      :href="`${RouteNames.NewExtract}?${ID_PARAM_FOR[objectType]}=${objectId}`"
      >Add extract in New extract task
    </a>
    <DisplayList
      :list="list"
      label="object_tag"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import DisplayList from '@/components/displayList.vue'
import { Extract } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import { ref } from 'vue'

import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { RouteNames } from '@/routes/routes'

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

Extract.where({
  [ID_PARAM_FOR[props.objectType]]: [props.objectId]
}).then(({ body }) => {
  list.value = body
})

function removeItem(item) {
  Extract.destroy(item.id)
    .then(() => {
      removeFromList(item)
    })
    .catch(() => {})
}
</script>
