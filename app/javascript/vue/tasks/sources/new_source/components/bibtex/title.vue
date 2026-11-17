<template>
  <div class="label-above">
    <label>Title</label>
    <ItalicsButton
      v-model="source.title"
      :textarea="titleRef"
    />
    <textarea
      id="title"
      ref="title"
      v-model="source.title"
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

const titleRef = useTemplateRef('title')
</script>
