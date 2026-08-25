<template>
  <div class="panel content sound-player">
    <div class="flex-separate middle">
      <h3>{{ sound.name || 'Sound' }}</h3>
      <div
        v-if="!sound.metadata.error"
        class="horizontal-left-content middle gap-medium"
      >
        <label class="horizontal-left-content gap-xsmall middle cursor-pointer">
          <input
            v-model="showRegions"
            type="checkbox"
          />
          Regions
        </label>
        <label class="horizontal-left-content gap-xsmall middle cursor-pointer">
          <input
            v-model="showSpectrogram"
            type="checkbox"
          />
          Spectrogram
        </label>
      </div>
    </div>

    <div
      v-if="sound.metadata.error"
      class="horizontal-left-content middle gap-small text-warning-color"
    >
      <VIcon
        name="attention"
        color="attention"
        small
      />
      <span>{{ sound.metadata.error }}</span>
    </div>

    <div
      v-else
      class="player-container"
      id="browse-sound-player"
    >
      <VSpinner
        v-if="isLoading"
        legend="Decoding audio..."
      />
      <AudioPlayer
        ref="audioPlayerRef"
        :url="sound.sound_file"
        :sample-rate="sampleRate"
        :regions="visibleRegions"
        :timeline="{ formatTimeCallback: regionTime }"
        :spectrogram="spectrogramOptions"
        media-controls
        @load="() => (isLoading = true)"
        @ready="() => (isLoading = false)"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref, useTemplateRef } from 'vue'
import { useUserPreference } from '@/composables'
import { secondsToTimeString } from '@/helpers'
import { fragmentConveyances, regionFillFor } from '../../utils/regionColors.js'
import AudioPlayer from '@/components/audio/AudioPlayer.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const KEY_SHOW_REGIONS = 'Task::BrowseSound::ShowRegions'
const KEY_SHOW_SPECTROGRAM = 'Task::BrowseSound::ShowSpectrogram'

const props = defineProps({
  sound: {
    type: Object,
    required: true
  },

  conveyances: {
    type: Array,
    default: () => []
  }
})

const audioPlayerRef = useTemplateRef('audioPlayerRef')
const isLoading = ref(false)
const showRegions = useUserPreference(KEY_SHOW_REGIONS, true)
const showSpectrogram = useUserPreference(KEY_SHOW_SPECTROGRAM, true)

const sampleRate = computed(() =>
  Math.min(Math.max(props.sound.metadata.sample_rate, 8000), 192000)
)

function regionTime(seconds) {
  return secondsToTimeString(seconds).split('.')[0]
}

const regions = computed(() =>
  fragmentConveyances(props.conveyances).map(
    ({ id, start_time, end_time }) => ({
      id: String(id),
      start: Number(start_time),
      end: Number(end_time),
      content: `${regionTime(start_time)} - ${regionTime(end_time)}`,
      color: regionFillFor(props.conveyances, id),
      drag: false,
      resize: false
    })
  )
)

const visibleRegions = computed(() => (showRegions.value ? regions.value : []))

const spectrogramOptions = computed(() =>
  showSpectrogram.value
    ? { frequencyMax: sampleRate.value, fftSamples: 2048 }
    : false
)

function playRegion(start, end) {
  audioPlayerRef.value?.play(Number(start), Number(end))
}

defineExpose({ playRegion })
</script>

<style scoped>
.player-container {
  position: relative;
  width: 100%;
}
</style>

<style>
#browse-sound-player ::part(wrapper) {
  margin-bottom: 1rem;
}

#browse-sound-player ::part(region-content) {
  font-size: var(--font-size-xs);
}
</style>
