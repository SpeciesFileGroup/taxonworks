<template>
  <div class="flex-row gap-small middle">
    <a
      :href="browseUrl"
      target="_blank"
      v-html="determinationLabel"
    />

    <RadialAnnotator :global-id="globalId" />
    <RadialObject
      :global-id="globalId"
      @change="(event) => emit('quickFormsChange', event)"
    />
    <RadialNavigator :global-id="globalId" />
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

defineOptions({ name: 'FieldOccurrenceLink' })

const emit = defineEmits(['quickFormsChange'])

defineProps({
  browseUrl: {
    type: String,
    required: true
  },

  globalId: {
    type: String,
    required: true
  },

  determinationLabel: {
    type: String,
    required: true
  }
})
</script>
