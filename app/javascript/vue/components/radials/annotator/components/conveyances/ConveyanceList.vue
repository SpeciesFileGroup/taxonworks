<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Name</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="conveyance in list"
        :key="conveyance.id"
      >
        <td>
          <div v-html="conveyance.object_tag" />
          <audio
            controls
            preload="metadata"
            :src="conveyance.sound.sound_file"
          />
        </td>
        <td>
          <div class="horizontal-left-content gap-small">
            <RadialAnnotator :global-id="conveyance.global_id" />

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

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['remove'])
</script>
