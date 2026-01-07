<template>
  <NavBar>
    <div class="flex-separate middle full_width">
      <VAutocomplete
        url="/leads/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a lead..."
        @select="({ id }) => store.loadKey(id)"
      />

      <label>
        <input
          type="checkbox"
          v-model="settings.indentation"
        />
        Tree style
      </label>
    </div>
  </NavBar>

  <div id="dichotomous-app">
    <PanelKey class="panel-key" />
    <ListRemaining
      class="panel-remaining"
      :list="store.remaining"
    />
    <ListEliminated
      class="panel-eliminated"
      :list="store.eliminated"
    />
  </div>
</template>

<script setup>
import useLeadStore from './store/lead.js'
import PanelKey from './components/PanelKey.vue'
import ListEliminated from './components/List/ListEliminated.vue'
import ListRemaining from './components/List/ListRemaining.vue'
import NavBar from '@/components/layout/NavBar.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import useSettingsStore from './store/settings.js'

defineOptions({
  name: 'DichotomousKey'
})

const store = useLeadStore()
const settings = useSettingsStore()

store.loadKey(1778)
</script>

<style>
#dichotomous-app {
  display: grid;
  gap: 1px;
  background-color: var(--border-color);
  grid-template-columns: repeat(2, 1fr);
  grid-template-rows: repeat(2, 1fr);
  max-height: calc(100vh - 140px);
  min-height: calc(100vh - 140px);
}

.panel-key {
  grid-column: span 2 / span 2;
}

.panel-key,
.panel-remaining,
.panel-eliminated {
  overflow: auto;
  background-color: var(--bg-foreground);
}
</style>
