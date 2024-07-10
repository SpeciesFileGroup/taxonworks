<template>
  <div class="horizontal-left-content align-start">
    <img :src="image.alternatives.thumb.image_file_url" />
    <ul>
      <li
        v-for="depiction in depictions"
        :key="depiction.id"
      >
        <span>{{ depiction.object_label }}</span>
        <RadialNavigator :global-id="depiction.global_id" />
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

const props = defineProps({
  image: {
    type: Object,
    required: true
  }
})

const depictions = ref([])

Depiction.where({
  image_id: [props.image.id],
  depiction_object_type: [COLLECTION_OBJECT]
}).then(({ body }) => {
  depictions.value = body
})
</script>
