<template>
  <div class="asserted_environments_annotator">
    <AutoselectField
      url="/asserted_environments/autoselect"
      param="uri"
      placeholder="Search ENVO, or terms already used in this project"
      reset-on-select
      @select="addFromSelection"
    />

    <DisplayList
      class="margin-medium-top"
      :list="list"
      label="uri_label"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import { AssertedEnvironment } from '@/routes/endpoints'
import DisplayList from '@/components/displayList.vue'
import AutoselectField from '@/components/ui/AutoselectField.vue'
import { useSlice } from '@/components/radials/composables'

const props = defineProps({
  objectType: {
    type: String,
    required: true
  },

  objectId: {
    type: Number,
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

function addFromSelection(item) {
  AssertedEnvironment.create({
    asserted_environment: {
      asserted_environment_object_id: props.objectId,
      asserted_environment_object_type: props.objectType,
      uri: item.response_values.uri,
      uri_label: item.response_values.uri_label
    }
  })
    .then(({ body }) => {
      addToList(body)
    })
    .catch(() => {})
}

function removeItem(item) {
  AssertedEnvironment.destroy(item.id).then(() => {
    removeFromList(item)
  })
}

AssertedEnvironment.where({
  asserted_environment_object_id: props.objectId,
  asserted_environment_object_type: props.objectType
}).then(({ body }) => {
  list.value = body
})
</script>

<style lang="scss">
.radial-annotator {
  .asserted_environments_annotator {
    padding-right: 1em;
  }
}
</style>
