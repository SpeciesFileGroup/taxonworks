<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Name</th>
        <th class="w-2">Sound</th>
        <th class="w-2" />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="conveyance in list"
        :key="conveyance.id"
      >
        <td>
          <div
            class="word_break"
            v-html="conveyance.object_tag"
          />
          <audio
            controls
            preload="metadata"
            :src="conveyance.sound.sound_file"
          />
        </td>
        <td>
          <RadialAnnotator :global-id="conveyance.sound.global_id" />
        </td>
        <td>
          <div class="horizontal-right-content gap-small">
            <RadialAnnotator :global-id="conveyance.global_id" />
            <VBtn
              color="primary"
              circle
              @click="() => emit('select', conveyance)"
            >
              <VIcon
                name="pencil"
                x-small
              />
            </VBtn>
            <MoveAnnotation
              :annotation="conveyance"
              @move="(item) => emit('move', item)"
            />
            <VBtn
              color="destroy"
              circle
              @click="() => emit('remove', conveyance)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import MoveAnnotation from '../shared/MoveAnnotation/MoveAnnotation.vue'

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select', 'remove', 'move'])
</script>
