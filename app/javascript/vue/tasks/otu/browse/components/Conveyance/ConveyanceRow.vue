<template>
  <tr>
    <td>
      <AudioPlayer
        ref="audioPlayerRef"
        :url="conveyance.sound.sound_file"
        @pause="() => (isPlaying = false)"
        @stop="() => (isPlaying = false)"
        @play="() => (isPlaying = true)"
      />
      <div v-html="conveyance.object_tag" />
    </td>
    <td class="w-2">
      <VBtn
        color="primary"
        circle
        class="player-button"
        @click="() => audioPlayerRef.playPause()"
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
    </td>
  </tr>
</template>

<script setup>
import { useTemplateRef, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import AudioPlayer from '@/components/audio/AudioPlayer.vue'
import IconPause from '@/components/Icon/IconPause.vue'
import IconPlay from '@/components/Icon/IconPlay.vue'

defineProps({
  conveyance: {
    type: Object,
    required: true
  }
})

const audioPlayerRef = useTemplateRef('audioPlayerRef')
const isPlaying = ref(false)
</script>

<style scoped>
.player-button {
  width: 48px;
  height: 48px;
  border-radius: 100%;
}
</style>
