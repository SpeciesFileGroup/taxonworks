<template>
  <tr>
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
      <div class="flex-wrap-column gap-small">
        <RadialAnnotator :global-id="depiction.global_id" />
        <VBtn
          class="circle-button"
          color="primary"
          circle
          @click="emit('selected', depiction)"
        >
          <VIcon
            name="pencil"
            x-small
          />
        </VBtn>
        <VBtn
          class="circle-button"
          color="destroy"
          circle
          @click="confirmDelete"
        >
          <VIcon
            name="trash"
            x-small
          />
        </VBtn>
      </div>
    </td>
  </tr>
</template>

<script setup>
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import EditInPlace from 'components/editInPlace.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { watch, ref } from 'vue'

const props = defineProps({
  depiction: {
    type: Object,
    required: true
  }
})

const emit = defineEmits([
  'selected',
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
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    emit('delete', props.depiction)
  }
}
</script>
