<template>
  <div>
    <ConveyanceMoveTo v-model="moveObj" />
    <div class="horizontal-left-content gap-small">
      <VBtn
        :disabled="!moveObj || isCurrent"
        medium
        color="create"
        @click="update"
      >
        Update
      </VBtn>
      <VBtn
        medium
        color="primary"
        @click="() => emit('new')"
      >
        New
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import ConveyanceMoveTo from './ConveyanceMoveTo.vue'

const props = defineProps({
  conveyence: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update', 'new'])
const moveObj = ref(null)
const name = ref(null)

const isCurrent = computed(
  () =>
    moveObj.value?.id === props.conveyence.conveyance_object_id &&
    moveObj.value?.type === props.conveyence.conveyance_object_type
)

name.value = props.conveyence.name

function update() {
  const payload = {
    id: props.conveyence.id,
    conveyance_object_id: moveObj.value?.id,
    conveyance_object_type: moveObj.value?.type
  }

  emit('update', payload)
}
</script>
