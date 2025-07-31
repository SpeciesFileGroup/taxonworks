<template>
  <div class="panel">
    <VModal
      v-if="showModal"
      @close="() => (showModal = false)"
    >
      <template #header>
        <h3>Confirm delete</h3>
      </template>
      <template #body>
        <div>Are you sure you want to delete {{ descriptor.object_tag }} ?</div>
      </template>
      <template #footer>
        <VBtn
          medium
          color="destroy"
          @click="() => emit('remove', descriptor)"
        >
          Delete
        </VBtn>
      </template>
    </VModal>
    <div class="content">
      <div
        v-if="descriptor.id"
        class="flex-separate middle"
      >
        <h3>{{ descriptor.object_tag }}</h3>
        <div class="horizontal-left-content middle gap-small">
          <RadialAnnotator :global-id="descriptor.global_id" />
          <VBtn
            circle
            color="destroy"
            @click="() => (showModal = true)"
          >
            <VIcon
              name="trash"
              color="white"
              x-small
            />
          </VBtn>
        </div>
      </div>
      <p v-show="descriptor.description">{{ descriptor.description }}</p>
    </div>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { ref } from 'vue'

defineProps({
  descriptor: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['remove'])

const showModal = ref(false)
</script>
