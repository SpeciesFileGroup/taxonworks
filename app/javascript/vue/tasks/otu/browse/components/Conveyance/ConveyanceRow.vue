<template>
  <tr>
    <td>
      <div
        class="horizontal-left-content middle gap-medium padding-medium-bottom padding-top-bottom region-sound-player"
      >
        <AudioPlayer
          class="full_width"
          media-controls
          :url="conveyance.sound.sound_file"
          :regions="regions"
        />
      </div>
      <div v-html="conveyance.object_tag" />
    </td>
  </tr>
</template>

<script setup>
import AudioPlayer from '@/components/audio/AudioPlayer.vue'
import { secondsToTimeString } from '@/helpers'
import { computed } from 'vue'

const props = defineProps({
  conveyance: {
    type: Object,
    required: true
  }
})

const regions = computed(() =>
  props.conveyance.start_time && props.conveyance.end_time
    ? [
        {
          content: `${secondsToTimeString(
            props.conveyance.start_time
          )} / ${secondsToTimeString(props.conveyance.end_time)}`,
          start: props.conveyance.start_time,
          end: props.conveyance.end_time,
          color: 'rgba(66, 249, 69, 0.5)',
          drag: false,
          resize: false
        }
      ]
    : undefined
)
</script>

<style scoped>
.player-button {
  width: 48px;
  height: 48px;
  min-width: 48px;
  min-height: 48px;
  border-radius: 100%;
}
</style>
