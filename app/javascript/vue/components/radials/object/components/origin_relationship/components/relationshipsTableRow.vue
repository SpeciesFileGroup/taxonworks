<template>
    <td v-html="element[`${t}_object_object_tag`]" />
    <td>{{ element[`${t}_object_type`] }}</td>
    <td>
      <div class="horizontal-right-content gap-small radials">
        <RadialAnnotator
          :global-id="element[`${t}_object_global_id`]"
        />
        <span
          class="circle-button btn-delete"
          @click="(element) => emit('remove', element)"
        />
      </div>
    </td>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

const props = defineProps({
  t: {
    type: String,
    required: true,
    validator: value => ['new', 'old'].includes(value)
  },

  element: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['remove'])

</script>