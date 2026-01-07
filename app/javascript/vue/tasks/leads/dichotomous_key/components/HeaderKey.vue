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
          @click="resetKey"
        >
          Reset
        </VBtn>
      </div>
    </template>
    <template v-else>
      <a :href="RouteNames.LeadsHub">Hub key</a>
    </template>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import useLeadStore from '../store/lead.js'
import useSettingsStore from '../store/settings.js'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { RouteNames } from '@/routes/routes.js'

const store = useLeadStore()
const settings = useSettingsStore()

const emit = defineEmits(['reset'])

const citations = computed(() =>
  store.root?.citations.map((c) => c.citation_source_body).join('; ')
)

function resetKey() {
  emit('reset')
  if (store.root.id !== store.lead.id) {
    store.loadKey(store.root.id)
  }
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
