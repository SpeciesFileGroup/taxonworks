<template>
  <VBtn
    color="primary"
    @click="clone"
  >
    Clone last
  </VBtn>
  <VSpinner
    v-if="isCloning"
    full-screen
    legend="Cloning... please wait."
  />
</template>

<script setup>
import { ref } from 'vue'
import { Container } from '@/routes/endpoints'
import { useContainerStore } from '../store'
import { makeContainer } from '../adapters'
import { CONTAINER_PARAMETERS } from '../constants'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const store = useContainerStore()
const isCloning = ref(false)

function clone() {
  isCloning.value = true

  Container.where({
    ...CONTAINER_PARAMETERS,
    recent: true,
    per: 1
  })
    .then(({ body }) => {
      const [container] = body

      store.$reset()

      if (container) {
        store.container = { ...makeContainer(container), id: null }
      } else {
        TW.workbench.alert.create('No container found.')
      }
    })
    .catch(() => {})
    .finally(() => {
      isCloning.value = false
    })
}
</script>
