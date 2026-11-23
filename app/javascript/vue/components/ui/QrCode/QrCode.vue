<template>
  <div
    class="qr-code"
    :style="{ width: size, height: size }"
    role="img"
    :aria-label="label"
    v-html="svg"
  />
</template>

<script setup>
// Displays a QR code rendered server-side (see QrCodeHelper). Never
// generates QR codes: those that carry authentication are created only on
// the server.
defineProps({
  svg: {
    type: String,
    required: true
  },

  size: {
    type: String,
    default: '240px'
  },

  label: {
    type: String,
    default: 'QR code'
  }
})
</script>

<style scoped>
.qr-code :deep(svg) {
  width: 100%;
  height: 100%;
}
</style>
