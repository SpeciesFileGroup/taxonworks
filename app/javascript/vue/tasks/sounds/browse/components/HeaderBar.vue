<template>
  <NavBar class="no-margin">
    <div class="flex-separate middle">
      <span
        v-if="sound"
        v-html="sound.object_tag"
      />
      <VAutocomplete
        v-else
        url="/sounds/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a sound..."
        autofocus
        @get-item="(item) => emit('select', item.id)"
      />
      <div
        v-if="sound"
        class="flex-row gap-small"
      >
        <RadialAnnotator :global-id="sound.global_id" />
        <RadialNavigator :global-id="sound.global_id" />
      </div>
    </div>
  </NavBar>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import NavBar from '@/components/layout/NavBar.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

defineProps({
  sound: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['select'])
</script>
