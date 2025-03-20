<template>
  <div class="panel content sound-player">
    <VSpinner v-if="isLoading" />
    <div class="horizontal-left-content middle gap-medium">
      <div
        class="full_width"
        id="browse-sound-player"
      >
        <AudioPlayer
          :url="sound.sound_file"
          ref="audioPlayerRef"
          :sample-rate="sampleRate"
          :spectrogram="{
            frequencyMax: sampleRate,
            fftSamples: 2048
          }"
          media-controls
          @load="() => (isLoading = true)"
          @ready="() => (isLoading = false)"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import AudioPlayer from '@/components/audio/AudioPlayer.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  sound: {
    type: Object,
    required: true
  }
})

const sampleRate = computed(() =>
  Math.min(Math.max(props.sound.metadata.sample_rate, 8000), 192000)
)
const isLoading = ref(false)
</script>

<style>
#browse-sound-player ::part(wrapper) {
  margin-bottom: 1rem;
}
</style>
