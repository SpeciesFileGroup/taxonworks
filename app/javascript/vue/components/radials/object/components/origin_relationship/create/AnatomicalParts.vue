<template>
  <div>
    <VSpinner
      v-if="isLoading"
    />

    <div class="flex-wrap-column gap-medium">
      <input
        class="normal-input"
        type="text"
        v-model="anatomicalPart.name"
        placeholder="Name"
      />

      or

      <input
        class="normal-input"
        type="text"
        v-model="anatomicalPart.uri"
        placeholder="URI"
      />
      <input
        class="normal-input"
        type="text"
        v-model="anatomicalPart.uri_label"
        placeholder="URI label"
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
      origin_object_id: props.objectId,
      origin_object_type: props.objectType
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
  if (props.originObjectType != 'AnatomicalPart') {
    anatomicalPart.value = {
     cached_otu_id: props.cachedOtuId
    }
  } else {
    // cachedOtuId of the new anatomical part should be the same as the origin
    // if the origin is an anatomical part.
    isLoading.value = true
    AnatomicalPart.find(props.originObjectId)
      .then(({ body }) => {
        anatomicalPart.value = {
          cached_otu_id: body.cached_otu_id
        }
      })
      .catch(() => {})
      .finally(() => (isLoading.value = false))

  }
})
</script>
