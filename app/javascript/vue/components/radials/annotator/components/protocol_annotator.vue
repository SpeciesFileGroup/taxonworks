<template>
  <div class="protocols_annotator">
    <SmartSelector
      model="protocols"
      :klass="objectType"
      @selected="({ id }) => createNew(id)"
    />
    <ListItems
      target="protocols"
      label="object_tag"
      :annotator="false"
      target-citations="protocols"
      :list="list"
      class="list"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import { ProtocolRelationship } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import ListItems from './shared/listItems'
import SmartSelector from '@/components/ui/SmartSelector.vue'

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

function createNew(protocolId) {
  const payload = {
    protocol_relationship: {
      protocol_id: protocolId,
      protocol_relationship_object_id: props.objectId,
      protocol_relationship_object_type: props.objectType
    }
  }

  ProtocolRelationship.create(payload).then(({ body }) => {
    addToList(body)
  })
}

function removeItem(item) {
  ProtocolRelationship.destroy(item.id).then((_) => {
    removeFromList(item)
  })
}

ProtocolRelationship.where({
  protocol_relationship_object_id: props.objectId,
  protocol_relationship_object_type: props.objectType
}).then(({ body }) => {
  list.value = body
})
</script>

<style lang="scss">
.radial-annotator {
  .protocols_annotator {
    .vue-autocomplete-input {
      width: 100%;
    }
  }
}
</style>
