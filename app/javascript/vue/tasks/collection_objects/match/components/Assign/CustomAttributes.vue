<template>
  <div class="panel content">
    <spinner-component
      v-if="isSaving"
      legend="Saving..."
    />
    <h2>Custom attributes</h2>
    <CustomAttributes
      :model="COLLECTION_OBJECT"
      :object-type="COLLECTION_OBJECT"
      :model-preferences="
        projectPreferences?.model_predicate_sets[COLLECTION_OBJECT]
      "
      @on-update="
        (attributes) => {
          dataAttributes = attributes
        }
      "
    />

    <div class="margin-medium-top">
      <button
        type="button"
        class="button normal-input button-submit"
        @click="setCustomAttributes()"
      >
        Update
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject, Project } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants'
import SpinnerComponent from '@/components/spinner'
import CustomAttributes from '@/components/custom_attributes/predicates/predicates.vue'

const MAX_PER_CALL = 5

const props = defineProps({
  ids: {
    type: Array,
    required: true
  }
})

const isSaving = ref(false)
const dataAttributes = ref([])
const preferences = {}

Project.preferences().then(({ body }) => {
  preferences.value = body
})

function setCustomAttributes(arrayIds = props.ids.slice()) {
  const ids = arrayIds.splice(0, MAX_PER_CALL)
  const requests = ids.map((id) => {
    const payload = {
      collection_object: {
        data_attributes_attributes: dataAttributes.value
      }
    }

    return CollectionObject.update(id, payload)
  })

  Promise.allSettled(requests).then(() => {
    if (arrayIds.length) {
      setCustomAttributes(dataAttributes.value, arrayIds)
    } else {
      isSaving.value = false
      TW.workbench.alert.create('Repository was successfully set.', 'notice')
    }
  })
}
</script>
