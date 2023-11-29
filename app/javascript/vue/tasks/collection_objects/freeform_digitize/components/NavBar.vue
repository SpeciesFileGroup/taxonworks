<template>
  <NavBar>
    <div class="full_width flex-separate middle">
      <DrawControls />
      <SaveButtons />
    </div>
  </NavBar>
</template>

<script setup>
import NavBar from '@/components/layout/NavBar'
import useImageStore from '../store/image'
import SaveButtons from './SaveButtons.vue'
import DrawControls from './DrawBoard/DrawControls.vue'

const imageStore = useImageStore()
</script>
