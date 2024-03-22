<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>

    <div class="flex-wrap-row gap-medium">
      <ul
        v-for="(itemsGroup, index) in preparationTypes"
        :key="index"
        class="no_bullets"
      >
        <li
          v-for="type in itemsGroup"
          :key="type.id"
        >
          <label>
            <input
              type="radio"
              :value="type.id"
              v-model="preparationTypeId"
              name="collection-object-type"
            />
            {{ type.name }}
          </label>
        </li>
      </ul>
    </div>
    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        @finalize="
          () => {
            updateBatchRef.openModal()
          }
        "
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { CollectionObject, PreparationType } from '@/routes/endpoints'
import { chunkArray } from '@/helpers'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

const MAX_LIMIT = 50

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const preparationTypeId = ref(null)
const preparationTypes = ref([])

const payload = computed(() => ({
  collection_object_query: props.parameters,
  collection_object: {
    preparation_type_id: preparationTypeId.value
  }
}))

PreparationType.all().then(({ body }) => {
  const types = [
    {
      id: null,
      name: 'None'
    },
    ...body
  ]

  preparationTypes.value = chunkArray(types, Math.ceil(types.length / 3))
})

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
