<template>
  <div>
    <div class="field">
      <label class="d-block">Sound name</label>
      <input
        v-model="name"
        type="text"
      />
      <VBtn
        class="margin-small-left"
        medium
        color="create"
        :disabled="!nameHasChanged"
        @click="
          emit('update:sound', {
            conveyanceId: conveyance.id,
            soundId: conveyance.sound_id,
            name
          })
        "
      >
        Update
      </VBtn>
    </div>
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
  conveyance: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update', 'update:sound', 'new'])
const moveObj = ref(null)
const name = ref(null)

const nameHasChanged = computed(
  () => name.value !== props.conveyance?.sound?.name
)

const isCurrent = computed(
  () =>
    moveObj.value?.id === props.conveyance.conveyance_object_id &&
    moveObj.value?.type === props.conveyance.conveyance_object_type
)

name.value = props.conveyance.sound.name

function update() {
  const payload = {
    id: props.conveyance.id,
    sound_id: props.conveyance.sound_id,
    conveyance_object_id: moveObj.value?.id,
    conveyance_object_type: moveObj.value?.type
  }

  emit('update', payload)
}
</script>
