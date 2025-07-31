<template>
  <div>
    <div
      v-for="depiction in depictions"
      :key="depiction.id"
      class="depiction-medium-image"
      @click="emit('select')"
    >
      <img :src="depiction.image.alternatives.medium.image_file_url" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { CHARACTER_STATE } from '@/constants'

const props = defineProps({
  characterState: {
    type: Object,
    required: true
  }
})
const emit = defineEmits(['select'])

const depictions = ref([])

Depiction.where({
  depiction_object_id: props.characterState.id,
  depiction_object_type: CHARACTER_STATE
}).then((response) => {
  depictions.value = response.body
})
</script>
