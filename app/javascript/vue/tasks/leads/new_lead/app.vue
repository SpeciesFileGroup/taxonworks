<template>
  <CornerSpinner :loading="store.loading" />
  <div class="flex-separate middle">
    <h1>
      {{ store.root.id ? 'Editing' : 'Create a new key' }}
    </h1>

    <VBtn
      :disabled="!store.lead.id"
      color="primary"
      title="Change layout"
      @click="changeLayout"
    >
      {{ layoutButtonText }}
    </VBtn>
  </div>

  <BlockLayout
    expand
    :set-expanded="!store.lead.id"
    @expanded-changed="(val) => (metaExpanded = val)"
    class="meta"
  >
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>{{ metadataTitle }}</h3>
        <div
          v-if="store.root.id"
          class="horizontal-right-content gap-small header-radials"
        >
          <RadialAnnotator
            :global-id="store.root.global_id"
            @create="handleRadialCreate"
            @delete="handleRadialDelete"
            @update="handleRadialUpdate"
          />
          <RadialNavigator
            :global-id="store.root.global_id"
            exclude="Edit"
          />
        </div>
      </div>
    </template>

    <template #body>
      <KeyMeta
        v-model:depiction="depictions"
        v-model:citation="citations"
      />
    </template>
  </BlockLayout>

  <component :is="LAYOUT_COMPONENTS[store.layout]" />

  <Couplet
    v-if="store.lead.id"
  />

</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import CornerSpinner from '../components/CornerSpinner.vue'
import Couplet from './shared/Couplet.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import KeyMeta from './shared/KeyMeta.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import setParam from '@/helpers/setParam'
import useStore from './store/leadStore.js'
import { computed, onBeforeMount, ref, watch } from 'vue'
import { CITATION, DEPICTION } from '@/constants'
import { useAnnotationHandlers } from './shared/composables/useAnnotationHandlers.js'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { usePopstateListener } from '@/composables'
import { nextLayout, LAYOUTS, LAYOUT_COMPONENTS } from './shared/layouts'

const LAYOUT_STORAGE_KEY = 'tw::leads::new::layout'

const store = useStore()
store.layout = LAYOUTS.PreviousFuture

const metaExpanded = ref(true)
const depictions = ref([])
const citations = ref([])
const layoutButtonText = ref(nextLayout().text)

const annotationLists = {
  [DEPICTION]: depictions,
  [CITATION]: citations
}
const {
  handleRadialCreate,
  handleRadialDelete,
  handleRadialUpdate
} = useAnnotationHandlers(annotationLists)

const metadataTitle = computed(() => {
  const defaultText = 'Key metadata'
  if (metaExpanded.value || !store.root.text) {
    return defaultText
  } else {
    return defaultText + ' - ' + store.root.text
  }
})

function changeLayout() {
  store.loadKey(store.lead.id, nextLayout().layout)
}

watch(() => store.layout, () => {
  layoutButtonText.value = nextLayout().text
  if (!store.layout) {
    store.layout = LAYOUTS.PreviousFuture
  }
  localStorage.setItem(LAYOUT_STORAGE_KEY, store.layout)
})

usePopstateListener(() => {
  const { lead_id } = URLParamsToJSON(location.href)
  if (lead_id) {
    store.loadKey(lead_id)
  } else {
    store.$reset()
  }
})

onBeforeMount(() => {
  const value = localStorage.getItem(LAYOUT_STORAGE_KEY)
  if (value !== null) {
    store.layout = value
  }

  const { lead_id } = URLParamsToJSON(location.href)

  if (lead_id) {
    // Call this for history.replaceState - it replaces turbolinks state
    // that would cause a reload every time we revisit this initial lead.
    setParam(RouteNames.NewLead, 'lead_id', lead_id)
    store.loadKey(lead_id)
  }
})
</script>

<style scoped>
.meta {
  max-width: 1240px;
  margin: 0 auto;
}

.header-radials {
  margin-right: .5em;
}
</style>
