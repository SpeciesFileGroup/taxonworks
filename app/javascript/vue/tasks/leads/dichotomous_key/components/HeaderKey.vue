<template>
  <div class="key-header">
    <template v-if="store.root">
      <div class="flex-row gap-small align-end">
        <div
          class="key-header-name"
          v-text="store.root.text"
        />
        <template v-if="citations">
          <span>-</span>
          <div>{{ citations }}</div>
        </template>
      </div>
      <div class="flex-row gap-small">
        <label>
          <input
            type="checkbox"
            v-model="settings.treeView"
          />
          Tree style
        </label>
        <RadialAnnotator :global-id="store.root.global_id" />
        <RadialNavigator :global-id="store.root.global_id" />
        <VBtn
          color="primary"
          @click="closeKey"
        >
          Close
        </VBtn>
      </div>
    </template>
    <template v-else>
      <VAutocomplete
        ref="autocomplete"
        url="/leads/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a lead..."
        @select="({ id }) => store.loadKey(id)"
      />
    </template>
  </div>
</template>

<script setup>
import { nextTick, useTemplateRef, computed } from 'vue'
import useLeadStore from '../store/lead.js'
import useSettingsStore from '../store/settings.js'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useLeadStore()
const settings = useSettingsStore()
const autocompleteRef = useTemplateRef('autocomplete')

const citations = computed(() =>
  store.root?.citations.map((c) => c.citation_source_body).join('; ')
)

function closeKey() {
  store.$reset()
  nextTick(() => {
    autocompleteRef.value.setFocus()
  })
}
</script>

<style scoped>
.key-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: var(--bg-foreground);
  border-bottom: 1px solid var(--border-color);
  padding: 1rem;
  border-top-left-radius: var(--border-radius-medium);
  border-top-right-radius: var(--border-radius-medium);
}

.key-header-name {
  font-size: 1.17rem;
  font-weight: bold;
}
</style>
