<template>
  <div class="flex-row gap-small middle">
    <a
      v-if="determinationLabel"
      :href="browseUrl"
      target="_blank"
      v-html="determinationLabel"
    />
    <a
      v-else
      :href="browseUrl"
      target="_blank"
    >Undetermined</a>
    <template v-if="globalId">
      <RadialAnnotator :global-id="globalId" />
      <RadialObject
        :global-id="globalId"
        @change="(event) => emit('quickFormsChange', event)"
      />
      <RadialNavigator :global-id="globalId" />
    </template>
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
    default: undefined
  },

  determinationLabel: {
    type: String,
    default: undefined
  }
})
</script>
