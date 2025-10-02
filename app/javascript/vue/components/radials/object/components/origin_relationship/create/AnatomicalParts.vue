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
  originObjectId: {
    type: Number,
    required: true
  },

  originObjectType: {
    type: String,
    required: true
  }
})

const anatomicalPart = ref({})
const isLoading = ref(false)

const emit = defineEmits(['create'])

const validAnatomicalPart = computed(() => {
  return anatomicalPart.value.name ||
    (anatomicalPart.value.uri && anatomicalPart.value.uri_label)
})

function save() {
  const payload = {
    anatomical_part: anatomicalPart.value
  }

  const response = anatomicalPart.id
    ? AnatomicalPart.update(anatomicalPart.id, payload)
    : AnatomicalPart.create(payload)

  isLoading.value = true
  response
    .then(({ body }) => {
      resetForm()
      emit('create', body)
      TW.workbench.alert.create('Anatomical part was successfully saved.', 'notice')
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
      taxonomic_origin_object_id: props.originObjectId,
      taxonomic_origin_object_type: props.originObjectType
    }
  } else {
    // taxonomic_origin_object of the new anatomical part should be the same as
    // the origin if the origin is an anatomical part.
    isLoading.value = true
    AnatomicalPart.find(props.originObjectId)
      .then(({ body }) => {
        anatomicalPart.value = {
          taxonomic_origin_object_id: body.taxonomic_origin_object_id,
          taxonomic_origin_object_type: body.taxonomic_origin_object_type
        }
      })
      .catch(() => {})
      .finally(() => (isLoading.value = false))

  }
})
</script>
