<template>
  <div
    :key="group.id"
    class="margin-small-bottom"
  >
    <span>{{ group.name }}</span>
    <div class="flex-wrap-row gap-small">
      <UpdateBatch
        v-for="item in group.list"
        :key="item.id"
        :batch-service="CollectionObject.batchUpdate"
        :payload="{
          collection_object_query: props.parameters,
          collection_object: {
            biocuration_classifications_attributes: [
              { biocuration_class_id: item.id }
            ]
          }
        }"
        :button-label="item.name"
        @update="updateMessage"
        @close="emit('close')"
      />
    </div>
  </div>
</template>

<script setup>
import { CollectionObject } from '@/routes/endpoints'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

const props = defineProps({
  group: {
    type: Object,
    required: true
  },

  color: {
    type: String,
    required: true
  },

  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['select'])
</script>
