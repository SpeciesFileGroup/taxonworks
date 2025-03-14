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
          :sample-rate="192000"
          :spectrogram="{
            frequencyMax: 192000,
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
import { ref } from 'vue'
import AudioPlayer from '@/components/audio/AudioPlayer.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineProps({
  sound: {
    type: Object,
    required: true
  }
})

const isLoading = ref(false)
</script>

<style>
#browse-sound-player ::part(wrapper) {
  margin-bottom: 1rem;
}
</style>
