<template>
  <div>
    <VSpinner
      v-if="isLoading"
    />

    <div>
      <fieldset>
        <legend>Name/URI</legend>
        <div class="margin-large-bottom">
          <input
            class="normal-input"
            type="text"
            v-model="anatomicalPart.name"
            placeholder="Name"
          />
        </div>

        or

        <div class="margin-large-top">
          <input
            class="normal-input"
            type="text"
            v-model="anatomicalPart.uri_label"
            placeholder="URI label"
          />
          <input
            class="normal-input input-width-large margin-medium-left"
            type="text"
            v-model="anatomicalPart.uri"
            placeholder="URI"
          />
        </div>
      </fieldset>

      <input
        class="margin-large-top margin-large-bottom"
        type="checkbox"
        v-model="anatomicalPart.is_material"
      >
        Is material
      </input>

      <PreparationType
        v-model="anatomicalPart"
      />

      <div class="horizontal-left-content gap-small">
        <VBtn
          :disabled="!validAnatomicalPart"
          color="create"
          medium
          @click="save"
        >
          {{ anatomicalPart.id ? 'Update' : 'Create' }}
        </VBtn>

        <VBtn
          color="primary"
          medium
          @click="() => (anatomicalPart = {})"
        >
          New
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
import PreparationType from './components/PreparationType.vue'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const anatomicalPart = ref({})
const isLoading = ref(false)

const emit = defineEmits(['originRelationshipCreated'])

const validAnatomicalPart = computed(() => {
  return anatomicalPart.value.name ||
    (anatomicalPart.value.uri && anatomicalPart.value.uri_label)
})

function save() {
  const payload = {
    anatomical_part: {
      ...anatomicalPart.value,
      inbound_origin_relationship_attributes: {
        old_object_id: props.objectId,
        old_object_type: props.objectType
      }
    }
  }

  const response = anatomicalPart.id
    ? AnatomicalPart.update(anatomicalPart.id, payload)
    : AnatomicalPart.create(payload)

  isLoading.value = true
  response
    .then(({ body }) => {
      resetForm()
      if (anatomicalPart.id) {
        TW.workbench.alert.create('Anatomical part was successfully saved.', 'notice')
      } else {
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
  if (props.objectType != 'AnatomicalPart') {
    let is_material = true
    if (props.objectType == 'Otu' || props.objectType == 'FieldOccurrence') {
      is_material = false
    }

    anatomicalPart.value = {
     cached_otu_id: props.cachedOtuId,
     is_material
    }
  } else {
    // cachedOtuId of the new anatomical part should be the same as the origin
    // if the origin is an anatomical part.
    isLoading.value = true
    AnatomicalPart.find(props.objectId)
      .then(({ body }) => {
        anatomicalPart.value = {
          cached_otu_id: body.cached_otu_id,
          is_material: body.is_material
        }
      })
      .catch(() => {})
      .finally(() => (isLoading.value = false))

  }
})
</script>

<style scoped>
.input-width-large {
  width: 600px;
}
</style>