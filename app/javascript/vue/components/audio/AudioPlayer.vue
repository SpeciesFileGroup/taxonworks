<template>
  <div ref="player" />
</template>

<script setup>
import { onMounted, useTemplateRef } from 'vue'
import WaveSurfer from 'wavesurfer.js'

const props = defineProps({
  waveColor: {
    type: String,
    default: '#4F4A85'
  },

  progressColor: {
    type: String,
    default: '#383351'
  },

  url: {
    type: String,
    required: true
  },

  width: {
    type: String,
    default: '100%'
  }
})

const emit = defineEmits(['play', 'pause', 'stop'])

const audioPlayerRef = useTemplateRef('player')
let audioPlayer

onMounted(() => {
  audioPlayer = WaveSurfer.create({
    container: audioPlayerRef.value,
    ...props
  })

  audioPlayer.on('play', () => emit('play'))
  audioPlayer.on('stop', () => emit('stop'))
  audioPlayer.on('pause', () => emit('pause'))
})

function play() {
  audioPlayer.play()
}

function stop() {
  audioPlayer.stop()
}

function playPause() {
  audioPlayer.playPause()
}

function pause() {
  audioPlayer.pause()
}

defineExpose({
  audioPlayer,
  play,
  stop,
  pause,
  playPause
})
</script>
