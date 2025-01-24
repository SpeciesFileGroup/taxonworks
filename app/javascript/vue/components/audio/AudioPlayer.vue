<template>
  <div ref="player" />
</template>

<script setup>
import { onMounted, useTemplateRef, onBeforeUnmount } from 'vue'
import WaveSurfer from 'wavesurfer.js'
import Spectrogram from 'wavesurfer.js/dist/plugins/spectrogram.esm.js'

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
  },

  spectrogram: {
    type: Boolean,
    default: false
  },

  timeline: {
    type: Boolean,
    default: false
  },

  mediaControls: {
    type: Boolean,
    default: false
  },

  sampleRate: {
    type: Number,
    default: 44100
  }
})

const emit = defineEmits(['load', 'ready', 'finish', 'play', 'pause', 'stop'])

const audioPlayerRef = useTemplateRef('player')
let audioPlayer

onMounted(() => {
  audioPlayer = WaveSurfer.create({
    container: audioPlayerRef.value,
    ...props
  })

  if (props.spectrogram) {
    audioPlayer.registerPlugin(
      Spectrogram.create({
        labels: true,
        height: 200,
        scale: 'mel',
        frequencyMax: 8000,
        frequencyMin: 0,
        fftSamples: 1024,
        labelsBackground: 'rgba(0, 0, 0, 0.1)'
      })
    )
  }

  audioPlayer.on('play', () => emit('play'))
  audioPlayer.on('stop', () => emit('stop'))
  audioPlayer.on('pause', () => emit('pause'))
  audioPlayer.on('load', (url) => emit('load', url))
  audioPlayer.on('finish', () => emit('finish'))
  audioPlayer.on('ready', (duration) => emit('ready', duration))
})

onBeforeUnmount(() => {
  audioPlayer.destroy()
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
