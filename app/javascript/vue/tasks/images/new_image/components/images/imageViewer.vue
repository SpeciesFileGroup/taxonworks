<template>
  <div class="depiction-thumb-container">
    <modal
      v-if="viewMode"
      @close="viewMode = false"
      :container-style="{
        width:
          (fullSizeImage ? image.width : image.alternatives.medium.width) + 'px'
      }"
    >
      <template #header>
        <h3>Image viewer</h3>
      </template>
      <template #body>
        <div>
          <img
            class="img-maxsize img-fullsize"
            v-if="fullSizeImage"
            @click="fullSizeImage = false"
            :src="image.image_file_url"
            :height="image.height"
            :width="image.width"
          />
          <img
            v-else
            class="img-maxsize img-normalsize"
            @click="fullSizeImage = true"
            :src="image.alternatives.medium.image_file_url"
            :height="image.alternatives.medium.height"
            :width="image.alternatives.medium.width"
          />
          <div class="flex-separate">
            <button
              type="button"
              @click="deleteImage"
              class="normal-input button button-delete"
            >
              Delete
            </button>
          </div>
        </div>
      </template>
    </modal>
    <img
      class="img-thumb"
      @click="viewMode = true"
      :src="image.alternatives.thumb.image_file_url"
      :height="image.alternatives.thumb.height"
      :width="image.alternatives.thumb.width"
    />
    <div class="flex-separate gap-xsmall">
      <RadialAnnotator
        type="annotations"
        :global-id="image.global_id"
      />
      <RadialObject :global-id="image.global_id" />
      <RadialNavigator :global-id="image.global_id" />
      <VBtn
        circle
        color="destroy"
        @click="deleteImage"
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
    </div>
  </div>
</template>
<script setup>
import { ref } from 'vue'
import Modal from '@/components/ui/Modal.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/object/radial'
import RadialNavigator from '@/components/radials/navigation/radial'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  image: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['delete'])

const fullSizeImage = ref(false)
const viewMode = ref(false)

function deleteImage() {
  if (window.confirm('Are you sure you want to delete this image?')) {
    emit('delete', props.image)
  }
}
</script>
<style lang="scss">
.depiction-thumb-container {
  margin: 4px;
  .img-thumb {
    cursor: pointer;
  }
  .img-maxsize {
    transition: all 0.5s ease;
    max-width: 100%;
    max-height: 60vh;
  }
  .img-fullsize {
    cursor: zoom-out;
  }
  .img-normalsize {
    cursor: zoom-in;
  }
  .field {
    input,
    textarea {
      width: 100%;
    }
  }
}
</style>
