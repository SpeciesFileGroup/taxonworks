<template>
  <div class="horizontal-left-content align-start">
    <VSpinner v-if="isLoading" />
    <div class="relative">
      <ImageViewer :image="image">
        <template #thumbfooter>
          <VBtn
            class="margin-small-top new-filename-image-remove"
            color="primary"
            circle
            title="Remove from list"
            @click="emit('remove', image)"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </template>
      </ImageViewer>
    </div>

    <b v-if="!isLoading && !depictions.length">No depictions found</b>
    <ul class="no_bullets">
      <li
        v-for="depiction in depictions"
        :key="depiction.id"
        class="padding-small"
      >
        <div class="horizontal-left-content middle gap-medium">
          <RadialNavigator
            :global-id="
              makeGlobalId({
                id: depiction.depiction_object_id,
                type: depiction.depiction_object_type
              })
            "
          />
          <span>{{ depiction.object_label }}</span>
        </div>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { makeGlobalId } from '@/helpers'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  image: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['remove'])

const depictions = ref([])
const isLoading = ref(true)

Depiction.where({
  image_id: [props.image.id]
})
  .then(({ body }) => {
    depictions.value = body
  })
  .finally(() => {
    isLoading.value = false
  })
</script>

<style scoped>
.new-filename-image-thumb {
  max-width: 100px;
  width: 100px;
  border: 1px solid var(--color-border);
}

.new-filename-image-remove {
  position: absolute;
  bottom: 0.5rem;
  right: 0.5rem;
}

li {
  border-bottom: 1px solid var(--color-border);
}

li:last-child {
  border-bottom: none;
}
</style>
