<template>
  <tr>
    <td>
      <div
        class="horizontal-left-content middle gap-medium padding-medium-bottom padding-top-bottom"
      >
        <AudioPlayer
          class="full_width"
          media-controls
          :url="conveyance.sound.sound_file"
        />
      </div>
      <div v-html="conveyance.object_tag" />
    </td>
  </tr>
</template>

<script setup>
import AudioPlayer from '@/components/audio/AudioPlayer.vue'

defineProps({
  conveyance: {
    type: Object,
    required: true
  }
})
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
