<template>
  <div class="task-container">
    <div class="flex-separate middle">
      <div class="flex-separate middle full_width">
        <h1>New filename depicting image</h1>
        <VBtn
          circle
          color="primary"
          @click="
            () => {
              images = []
              error = []
            }
          "
        >
          <VIcon
            name="undo"
            small
          />
        </VBtn>
      </div>
    </div>
    <div class="flexbox gap-medium">
      <PanelImage
        v-model="images"
        v-model:error="error"
      />
      <PanelDepictions v-model="images" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import PanelDepictions from './components/PanelDepictions.vue'
import PanelImage from './components/PanelImage.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const images = ref([])
const error = ref([])
</script>

<style scoped>
.task-container {
  margin: 1em auto;
  max-width: 1240px;
}
</style>
