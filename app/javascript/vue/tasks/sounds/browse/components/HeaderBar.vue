<template>
  <NavBar navbar-class="panel content rounded-tl-none rounded-tr-none">
    <div class="flex-separate middle gap-medium">
      <div class="horizontal-left-content middle gap-medium sound-identity">
        <VAutocomplete
          ref="autocompleteRef"
          class="sound-autocomplete"
          url="/sounds/autocomplete"
          param="term"
          label="label_html"
          placeholder="Search a sound..."
          clear-after
          autofocus
          @get-item="(item) => emit('select', item.id)"
        />
        <span
          v-if="sound"
          class="truncate"
          v-html="sound.object_tag"
        />
      </div>
      <div
        v-if="sound"
        class="flex-row middle gap-small"
      >
        <VBtn
          v-if="!sound.metadata.error"
          circle
          color="primary"
          :href="sound.sound_file"
          download
          title="Download sound file"
        >
          <VIcon
            name="download"
            x-small
          />
        </VBtn>
        <RadialAnnotator :global-id="sound.global_id" />
        <RadialObject :global-id="sound.global_id" />
        <RadialNavigator :global-id="sound.global_id" />
      </div>
    </div>
  </NavBar>
</template>

<script setup>
import { useTemplateRef } from 'vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import NavBar from '@/components/layout/NavBar.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'

defineProps({
  sound: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['select'])
const autocompleteRef = useTemplateRef('autocompleteRef')

defineExpose({
  setFocus: () => autocompleteRef.value?.setFocus()
})
</script>

<style scoped>
.sound-identity {
  min-width: 0;
}

.sound-autocomplete {
  width: 400px;
  flex-shrink: 0;
}

.truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
