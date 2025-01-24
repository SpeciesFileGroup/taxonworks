<template>
  <NavBar>
    <span
      v-if="sound"
      v-html="sound.object_tag"
    />
    <VAutocomplete
      v-else
      url="/sounds/autocomplete"
      param="term"
      label="label_html"
      @get-item="(item) => emit('select', item.id)"
    />
    <ul
      v-if="sound"
      class="context-menu"
    >
      <li><RadialAnnotator :global-id="sound.global_id" /></li>
    </ul>
  </NavBar>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import NavBar from '@/components/layout/NavBar.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

defineProps({
  sound: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['select'])
</script>
