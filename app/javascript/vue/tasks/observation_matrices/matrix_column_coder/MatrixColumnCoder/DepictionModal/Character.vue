<template>
  <div>
    <div
      v-for="depiction in depictions"
      :key="depiction.id"
      class="depiction-medium-image"
      @click="emit('select')"
    >
      <img :src="depiction.image.alternatives.medium.image_file_url">
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { CharacterState } from 'routes/endpoints'

const props = defineProps({
  characterState: {
    type: Object,
    required: true
  }
})
const emit = defineEmits(['select'])

const depictions = ref([])

CharacterState.depictions(props.characterState.id).then(response => {
  depictions.value = response.body
})
</script>
