<template>
  <tr class="list-complete-item contextMenuCells">
    <td>
      <input
        v-model="selectedCEIds"
        :value="collectingEvent.id"
        type="checkbox"
      />
    </td>
    <td>
      {{ collectingEvent.id }}
    </td>
<!--    <td v-if="collectingEvent.images.length">-->
<!--      <template v-if="isImageColumnVisible">-->
<!--        <ImageViewer-->
<!--          v-for="image in collectingEvent.images"-->
<!--          :key="image.image_id"-->
<!--          :image="image"-->
<!--          :edit="false"-->
<!--        />-->
<!--      </template>-->
<!--      <VBtn-->
<!--        v-else-->
<!--        circle-->
<!--        color="primary"-->
<!--        @click="isImageColumnVisible = true"-->
<!--      >-->
<!--        <VIcon-->
<!--          name="image"-->
<!--          x-small-->
<!--        />-->
<!--      </VBtn>-->
<!--    </td>-->
<!--    <td v-else />-->
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
      <CollectingEventDwc
        v-if="isDwCVisible"
        :collecting-event-id="collectingEvent.id"
        @close="isDwCVisible = false"
      />
    </td>
    <td>
      <span v-html="collectingEvent.object_tag" />
    </td>
    <td>
      <div class="horizontal-left-content middle">
        <span v-html="collectingEvent.verbatimCollector" />
        <VIcon
          v-if="selectedCollectorString.value !== collectingEvent.verbatim_collectors"
          class="margin-small-left"
          title="Whitespace difference"
          name="attention"
          color="attention"
          small
        />
      </div>
    </td>
    <td>
      <RadialNavigator :global-id="collectingEvent.global_id" />
    </td>
  </tr>
</template>

<script setup>
import { computed, ref } from 'vue'
import useStore from '../../composables/useStore'
import CollectingEventDwc from './CollectingEventDwc.vue'
// import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const { selectedCollectorString } = useStore()

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  },

  collectingEvent: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

// const isImageColumnVisible = ref(false)
const isDwCVisible = ref(false)

const selectedCEIds = computed({
  get() {
    return props.modelValue
  },

  set(value) {
    emit('update:modelValue', value)
  }
})
</script>
