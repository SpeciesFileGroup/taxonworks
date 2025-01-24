<template>
  <div class="panel content">
    <div class="horizontal-left-content middle gap-medium">
      <div class="full_width">
        <AudioPlayer
          :url="sound.sound_file"
          ref="audioPlayerRef"
        />
      </div>
      <VBtn
        color="primary"
        circle
        class="player-button"
        @click="() => audioPlayer.playPause()"
      >
        <IconPause
          v-if="isPlaying"
          height="24px"
          width="24px"
        />
        <IconPlay
          v-else
          height="24px"
          width="24px"
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { onMounted, useTemplateRef } from 'vue'
import AudioPlayer from '@/components/audio/AudioPlayer.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconPause from '@/components/Icon/IconPause.vue'
import IconPlay from '@/components/Icon/IconPlay.vue'

defineProps({
  sound: {
    type: Object,
    required: true
  }
})

const audioPlayer = useTemplateRef('audioPlayerRef')

onMounted(() => {})
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
