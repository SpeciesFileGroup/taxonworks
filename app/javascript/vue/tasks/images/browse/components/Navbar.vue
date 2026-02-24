<template>
  <VNavbar>
    <div class="flex-separate">
      <div class="horizontal-left-content gap-small">
        <VAutocomplete
          url="/images/autocomplete"
          param="term"
          placeholder="Search an image..."
          label="label_html"
          clear-after
          @select="(e) => emit('select', e.id)"
        />
        <span v-if="store.image">Image ID {{ store.image?.id }}</span>
      </div>
      <div
        v-if="store.image"
        class="horizontal-left-content gap-small"
      >
        <RadialAnnotator :global-id="store.image.globalId" />
        <RadialObject :global-id="store.image.globalId" />
        <RadialNavigator :global-id="store.image.globalId" />
      </div>
    </div>
  </VNavbar>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VNavbar from '@/components/layout/NavBar.vue'
import useStore from '../store/store.js'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'

const emit = defineEmits(['select'])

const store = useStore()
</script>
