<template>
  <tr class="list-complete-item contextMenuCells">
    <td>
      <input
        v-model="selectedCOIds"
        :value="collectionObject.id"
        type="checkbox"
      >
    </td>
    <td>
      {{ collectionObject.id }}
    </td>
    <td v-if="collectionObject.images.length">
      <template v-if="isImageColumnVisible">
        <ImageViewer
          v-for="image in collectionObject.images"
          :key="image.image_id"
          :image="image"
          :edit="false"
        />
      </template>
      <VBtn
        v-else
        circle
        color="primary"
        @click="isImageColumnVisible = true"
      >
        <VIcon
          name="image"
          x-small
        />
      </VBtn>
    </td>
    <td v-else />
    <td>
      <VBtn
        circle
        color="primary"
        @click="isDwCVisible = true"
      >
        <VIcon
          name="expand"
          x-small
        />
      </VBtn>
      <CollectionObjectDwc
        v-if="isDwCVisible"
        :collection-object-id="collectionObject.id"
        @close="isDwCVisible = false"
      />
    </td>
    <td>
      <span v-html="collectionObject.object_tag" />
    </td>
    <td>
      <div class="horizontal-left-content middle">
        <span
          v-html="collectionObject.bufferedDeterminations"
        />
        <VIcon
          v-if="selectedLabel !== collectionObject.bufferedDeterminations"
          class="margin-small-left"
          title="Whitespace difference"
          name="attention"
          color="attention"
          small
        />
      </div>
    </td>
    <td>
      <RadialNavigator :global-id="collectionObject.global_id" />
    </td>
  </tr>
</template>

<script setup>

import { computed, ref } from 'vue'
import useStore from '../../composables/useStore'
import CollectionObjectDwc from './CollectionObjectDwc.vue'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import RadialNavigator from 'components/radials/navigation/radial.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const {
  selectedLabel
} = useStore()

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  },

  collectionObject: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const isImageColumnVisible = ref(false)
const isDwCVisible = ref(false)

const selectedCOIds = computed({
  get () {
    return props.modelValue
  },

  set (value) {
    emit('update:modelValue', value)
  }
})

</script>
