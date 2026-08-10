<template>
  <tr>
    <td>
      <DragHandle
        color="create"
        label="depiction"
      />
    </td>
    <td v-html="depiction.object_tag" />
    <td>{{ depiction.is_metadata_depiction }}</td>
    <td>
      <EditInPlace
        v-model="label"
        @end="emit('update:label', label)"
      />
    </td>
    <td>
      <EditInPlace
        v-model="caption"
        @end="emit('update:caption', caption)"
      />
    </td>
    <td>
      <RadialAnnotator :global-id="depiction.image.global_id" />
    </td>
    <td>
      <div
        class="flex-wrap-column gap-small padding-small-top padding-small-bottom"
      >
        <RadialAnnotator :global-id="depiction.global_id" />
        <MoveAnnotation
          :annotation="depiction"
          @move="(item) => emit('move', item)"
        />
        <VBtn
          class="circle-button"
          color="primary"
          icon
          variant="tonal"
          @click="emit('selected', depiction)"
        >
          <IconPencil class="w-4 h-4" />
        </VBtn>

        <VBtn
          color="destroy"
          icon
          variant="tonal"
          @click="confirmDelete"
        >
          <IconTrash class="w-4 h-4" />
        </VBtn>
      </div>
    </td>
  </tr>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import EditInPlace from '@/components/editInPlace.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import DragHandle from '@/components/ui/DragHandle/DragHandle.vue'
import IconPencil from '@/components/Icon/IconPencil.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import MoveAnnotation from '../shared/MoveAnnotation/MoveAnnotation.vue'
import { watch, ref } from 'vue'

const props = defineProps({
  depiction: {
    type: Object,
    required: true
  }
})

const emit = defineEmits([
  'selected',
  'move',
  'delete',
  'update:label',
  'update:caption'
])

const caption = ref('')
const label = ref('')

watch(
  () => props.depiction.caption,
  (newVal) => {
    caption.value = newVal
  },
  { immediate: true }
)

watch(
  () => props.depiction.figure_label,
  (newVal) => {
    label.value = newVal
  },
  { immediate: true }
)

function confirmDelete() {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure you want to proceed?"
    )
  ) {
    emit('delete', props.depiction)
  }
}
</script>
