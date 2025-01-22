<template>
  <h1>Browse sound</h1>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { Sound } from '@/routes/endpoints'
import { getPagination, URLParamsToJSON } from '@/helpers'
import VPagination from '@/components/pagination.vue'

const per = ref(50)
const list = ref([])
const page = ref(1)
const currentSound = ref(null)
const pagination = ref(null)

Sound.where({ per: 50 }).then((response) => {
  pagination.value = response
})

onBeforeMount(() => {
  const params = URLParamsToJSON(window.location.href)
  const soundId = params.sound_id

  if (soundId) {
    Sound.find(soundId).then(({ body }) => {
      currentSound.value = body
    })
  }
})
</script>
