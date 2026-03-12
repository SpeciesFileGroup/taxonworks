<template>
  <div id="vue-dichotomous-app">
    <VSpinner v-if="settings.isLoading" />
    <HeaderKey @reset="scrollPanelKey" />
    <div
      id="dichotomous-container"
      :class="['dichotomous-grid', settings.layout]"
    >
      <PanelKey
        class="panel-key"
        ref="panelKey"
      />
      <ListRemaining
        class="panel-remaining"
        :list="store.remaining"
      />
      <ListEliminated
        class="panel-eliminated"
        :list="store.eliminated"
      />
    </div>
  </div>
</template>

<script setup>
import { onBeforeMount, useTemplateRef, ref, watch } from 'vue'
import { usePopstateListener } from '@/composables'
import { URLParamsToJSON, setParam } from '@/helpers/index.js'
import { RouteNames } from '@/routes/routes.js'
import VSpinner from '@/components/ui/VSpinner.vue'
import useLeadStore from './store/lead.js'
import PanelKey from './components/PanelKey.vue'
import ListEliminated from './components/List/ListEliminated.vue'
import ListRemaining from './components/List/ListRemaining.vue'
import HeaderKey from './components/HeaderKey.vue'
import useSettingsStore from './store/settings.js'

defineOptions({
  name: 'DichotomousKey'
})

const store = useLeadStore()
const settings = useSettingsStore()

const panelKeyRef = useTemplateRef('panelKey')

function loadFromUrlParam() {
  const { lead_id } = URLParamsToJSON(location.href)

  if (lead_id) {
    store.loadKey(lead_id)
  } else {
    store.$reset()
  }
}

function scrollPanelKey() {
  panelKeyRef.value.$el.scrollTo({ top: 0, behavior: 'smooth' })
}

watch(
  () => store.lead?.id,
  (id) => {
    setParam(RouteNames.DichotomousKey, 'lead_id', id)
  }
)

onBeforeMount(loadFromUrlParam)
usePopstateListener(loadFromUrlParam)
</script>

<style>
#vue-dichotomous-app {
  box-shadow: var(--panel-shadow);
  margin-top: 1rem;

  #dichotomous-container {
    background-color: var(--border-color);

    max-height: calc(100vh - 140px);
    min-height: calc(100vh - 140px);
  }

  .dichotomous-grid {
    display: grid;
    gap: 1px;
    grid-template-columns: repeat(2, 1fr);
    grid-template-rows: repeat(2, 1fr);
  }

  .layout-1 {
    .panel-key {
      grid-column: span 2 / span 2;
    }
  }

  .layout-2 {
    .panel-key {
      grid-row: span 2 / span 2;
    }

    .panel-remaining {
      grid-column-start: 2;
    }
  }

  .panel-key,
  .panel-remaining,
  .panel-eliminated {
    overflow: auto;
    background-color: var(--bg-foreground);
  }
}
</style>
