<template>
  <div class="depiction-thumb-container">
    <ImageViewer
      edit
      :depiction="depiction"
    >
      <template #thumbfooter>
        <div
          class="horizontal-left-content padding-xsmall-top padding-xsmall-bottom"
        >
          <VBtn
            color="destroy"
            circle
            @click="deleteDepiction"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </div>
      </template>
    </ImageViewer>
  </div>
</template>
<script setup>
import ImageViewer from 'components/ui/ImageViewer/ImageViewer'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  depiction: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['delete'])

function deleteDepiction() {
  emit('delete', props.depiction)
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
  .img-box {
    position: relative;
  }
  .annotator {
    position: absolute;
    right: 10px;
    top: 10px;
  }
}
</style>
