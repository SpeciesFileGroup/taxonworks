<template>
  <div>
    <div
      id="radial-sound-player"
      class="field"
    >
      <AudioPlayer
        media-controls
        :url="conveyance.sound.sound_file"
        :regions="regions"
        @region:updated="updateRegion"
      />
    </div>
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
        :disabled="!timeHasChanged && (!moveObj || isCurrent)"
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
import AudioPlayer from '@/components/audio/AudioPlayer.vue'
import { secondsToTimeString } from '@/helpers'

const props = defineProps({
  conveyance: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update', 'update:sound', 'new'])
const moveObj = ref(null)
const name = ref(null)

const endTime = ref(
  Number(props.conveyance.end_time || props.conveyance.sound.metadata.duration)
)
const startTime = ref(Number(props.conveyance.start_time) || 0)
const currentStartTime = ref(startTime.value)
const currentEndTime = ref(endTime.value)

const regions = computed(() => [
  {
    content: `${secondsToTimeString(
      currentStartTime.value
    )} / ${secondsToTimeString(currentEndTime.value)}`,
    start: currentStartTime.value,
    end: currentEndTime.value,
    color: 'rgba(66, 249, 69, 0.5)',
    drag: true
  }
])
const nameHasChanged = computed(
  () => name.value !== props.conveyance?.sound?.name
)

const timeHasChanged = computed(
  () =>
    startTime.value !== currentStartTime.value ||
    endTime.value !== currentEndTime.value
)

function updateRegion(region) {
  currentStartTime.value = region.start
  currentEndTime.value = region.end
}

const isCurrent = computed(
  () =>
    moveObj.value?.id === props.conveyance.conveyance_object_id &&
    moveObj.value?.type === props.conveyance.conveyance_object_type
)

name.value = props.conveyance.sound.name

function update() {
  const payload = {
    id: props.conveyance.id,
    sound_id: props.conveyance.sound_id
  }

  if (moveObj.value) {
    Object.assign(payload, {
      conveyance_object_id: moveObj.value?.id,
      conveyance_object_type: moveObj.value?.type
    })
  }

  if (timeHasChanged.value) {
    Object.assign(payload, {
      start_time: currentStartTime.value,
      end_time: currentEndTime.value
    })
  }

  emit('update', payload)
}
</script>
<style>
text {
}
#radial-sound-player ::part(region-content) {
  background-color: rgba(0, 0, 0, 0.3);
  filter: drop-shadow(0 1px 2px #000000);
  color: white;
  font-weight: 500;
}
</style>
