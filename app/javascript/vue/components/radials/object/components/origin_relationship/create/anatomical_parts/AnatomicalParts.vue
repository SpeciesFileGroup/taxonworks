<template>
  <div>
    <VSpinner
      v-if="isLoading"
    />

    <div>
      <AnatomicalPartFormFields
        v-model="anatomicalPart"
        include-is-material
        show-ontology-search
        preparation-type-display="radio"
      />

      <div class="horizontal-left-content gap-small margin-large-top margin-large-bottom">
        <VBtn
          :disabled="!validAnatomicalPart"
          color="create"
          medium
          @click="save"
        >
          {{ anatomicalPart.id ? 'Update' : 'Create' }}
        </VBtn>

        <VBtn
          v-if="!anatomicalPart.id"
          color="primary"
          medium
          @click="() => (anatomicalPart = {})"
        >
          Reset
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { AnatomicalPart } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import AnatomicalPartFormFields from './components/AnatomicalPartFormFields.vue'
import { URLParamsToJSON } from '@/helpers'
import { CREATE_VERB, EDIT_VERB } from '@/constants'

const props = defineProps({
  objectId: {
    type: Number,
    required: false
  },

  objectType: {
    type: String,
    required: false
  },

  mode: {
    type: String,
    default: undefined,
    validator: (value) => {
      return [undefined, CREATE_VERB, EDIT_VERB].includes(value)
    }
  }
})

const anatomicalPart = ref({})
const isLoading = ref(false)

const emit = defineEmits([
  'originRelationshipCreated', 'originRelationshipUpdated',
  'anatomicalPartLoaded'
])

const validAnatomicalPart = computed(() => {
  return anatomicalPart.value.name ||
    (anatomicalPart.value.uri && anatomicalPart.value.uri_label)
})

function save() {
  const payload = anatomicalPart.value.id ?
  { anatomical_part: anatomicalPart.value } :
  {
    anatomical_part: {
      ...anatomicalPart.value,
      inbound_origin_relationship_attributes: {
        old_object_id: props.objectId,
        old_object_type: props.objectType
      }
    }
  }

  const response = anatomicalPart.value.id
    ? AnatomicalPart.update(anatomicalPart.value.id, payload)
    : AnatomicalPart.create(payload)

  isLoading.value = true
  response
    .then(({ body }) => {
      if (anatomicalPart.value.id) {
        emit('originRelationshipUpdated', body.origin_relationship)
        TW.workbench.alert.create('Anatomical part was successfully saved.', 'notice')
      } else {
        resetForm()
        emit('originRelationshipCreated', body.origin_relationship)
        TW.workbench.alert.create('Anatomical part and Origin relationship were successfully created.', 'notice')
      }
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function resetForm() {
  anatomicalPart.value = {}
}

onMounted(() => {
  const anatomicalPartId = URLParamsToJSON(location.href).anatomical_part_id
  if (anatomicalPartId && !props.mode) { // Edit task
    isLoading.value = true
    AnatomicalPart.find(anatomicalPartId)
      .then(({ body }) => {
        anatomicalPart.value = body
        emit('anatomicalPartLoaded', anatomicalPart.value)
      })
      .catch(() => {})
      .finally(() => (isLoading.value = false))

  } else {
    if (props.objectType != 'AnatomicalPart') { // Create new part
      let is_material = true
      if (props.objectType == 'Otu' || props.objectType == 'FieldOccurrence') {
        is_material = false
      }

      anatomicalPart.value = {
        cached_otu_id: props.cachedOtuId,
        is_material
      }
    } else {
      isLoading.value = true
      AnatomicalPart.find(props.objectId)
        .then(({ body }) => {
          if (props.mode == EDIT_VERB) {
            anatomicalPart.value = body
          } else { // # Create new part
            // cachedOtuId of the new anatomical part should be the same as the
            // origin if the origin is an anatomical part.
            anatomicalPart.value = {
              cached_otu_id: body.cached_otu_id,
              is_material: body.is_material
            }
          }
        })
        .catch(() => {})
        .finally(() => (isLoading.value = false))
    }
  }

})
</script>
