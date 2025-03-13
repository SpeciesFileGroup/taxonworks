<template>
  <div ref="player" />
</template>

<script setup>
import { onMounted, useTemplateRef, onBeforeUnmount, watch } from 'vue'
import WaveSurfer from 'wavesurfer.js'
import Spectrogram from 'wavesurfer.js/dist/plugins/spectrogram.esm.js'
import RegionsPlugin from 'wavesurfer.js/dist/plugins/regions.esm.js'

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
    type: [Boolean, Object],
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
  },

  regions: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'load',
  'ready',
  'finish',
  'play',
  'pause',
  'stop',
  'region:created',
  'region:click',
  'region:dblclick',
  'region:in',
  'region:out',
  'region:removed',
  'region:update',
  'region:updated'
])

const audioPlayerRef = useTemplateRef('player')
let audioPlayer
let regionsPlugin

onMounted(() => {
  const plugins = []

  if (props.regions.length) {
    regionsPlugin = RegionsPlugin.create()

    regionsPlugin.on('region-clicked', (r, e) =>
      emit('region:click', { region: r, event: e })
    )
    regionsPlugin.on('region-created', (e) => emit('region:created', e))
    regionsPlugin.on('region-double-click', (e) => emit('region:dblclick', e))
    regionsPlugin.on('region-in', (e) => emit('region:in', e))
    regionsPlugin.on('region-out', (e) => emit('region:out', e))
    regionsPlugin.on('region-removed', (e) => emit('region:removed', e))
    regionsPlugin.on('region-update', (e) => emit('region:update', e))
    regionsPlugin.on('region-updated', (e) => emit('region:updated', e))

    plugins.push(regionsPlugin)
  }

  audioPlayer = WaveSurfer.create({
    container: audioPlayerRef.value,
    plugins,
    ...props
  })

  if (props.spectrogram) {
    audioPlayer.registerPlugin(
      Spectrogram.create({
        labels: true,
        height: 400,
        scale: 'mel',
        labelsBackground: 'rgba(0, 0, 0, 0.1)',
        ...props.spectrogram
      })
    )
  }

  if (props.regions.length) {
    audioPlayer.on('decode', () => {
      props.regions.forEach((region) =>
        regionsPlugin.addRegion(makeRegion(region))
      )
    })
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

function makeRegion(region) {
  const random = (min, max) => Math.random() * (max - min) + min
  const randomColor = () =>
    `rgba(${random(0, 255)}, ${random(0, 255)}, ${random(0, 255)}, 0.5)`

  return {
    content: '',
    color: randomColor(),
    drag: false,
    resize: true,
    ...region
  }
}

function load(url) {
  audioPlayer.load(url)
}

function play() {
  audioPlayer.play()
}

function stop() {
  audioPlayer.stop()
}

function clearRegions() {
  regionsPlugin?.clearRegions()
}

function destroyRegions() {
  regionsPlugin?.destroy()
}

function playPause() {
  audioPlayer.playPause()
}

function pause() {
  audioPlayer.pause()
}

watch(
  () => props.url,
  (url) => load(url)
)

watch(
  () => props.regions,
  (newVal) => {
    regionsPlugin.clearRegions()

    newVal.forEach((region) => {
      regionsPlugin.addRegion(makeRegion(region))
    })
  }
)

defineExpose({
  audioPlayer,
  regionsPlugin,
  load,
  play,
  stop,
  pause,
  playPause,
  clearRegions,
  destroyRegions
})
</script>
