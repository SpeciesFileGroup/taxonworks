<template>
  <div class="label-above">
    <label>Abstract</label>
    <ItalicsButton
      v-model="source.abstract"
      :textarea="abstractRef"
    />
    <textarea
      ref="abstract"
      v-model="source.abstract"
      @change="() => (source.isUnsaved = true)"
    ></textarea>
  </div>
</template>

<script setup>
import { useTemplateRef } from 'vue'
import ItalicsButton from './ItalicsButton.vue'

const source = defineModel({
  type: Object,
  required: true
})

const abstractRef = useTemplateRef('abstract')
</script>
