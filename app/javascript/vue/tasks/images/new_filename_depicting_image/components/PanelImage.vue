<template>
  <BlockLayout>
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>Images</h3>
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
    </template>
    <template #body>
      <ImageDropzone
        v-model="images"
        v-model:error="error"
      />
      <ImageErrorList
        v-if="error.length"
        v-model="error"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ImageDropzone from './ImageDropzone.vue'
import ImageErrorList from './ImageErrorList.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const images = defineModel({
  type: Array,
  required: true
})

const error = defineModel('error', {
  type: Array,
  required: true
})
</script>
