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

  <Couplet v-if="store.lead.id" />

  <div class="show-key-otus-lists">
    <ListRemaining :list="store.remaining" />
    <ListEliminated :list="store.eliminated" />
  </div>
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
import ListEliminated from '@/tasks/leads/show/components/List/ListEliminated.vue'
import ListRemaining from '@/tasks/leads/show/components/List/ListRemaining.vue'
import { computed, onBeforeMount, ref, watch } from 'vue'
import { CITATION, DEPICTION } from '@/constants'
import { useAnnotationHandlers } from './shared/composables/useAnnotationHandlers.js'
import { RouteNames } from '@/routes/routes'
import { usePopstateListener } from '@/composables'
import { nextLayout, LAYOUTS, LAYOUT_COMPONENTS } from './shared/layouts'
import { useParamsSessionPop } from '@/composables/useParamsSessionPop'

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
const { handleRadialCreate, handleRadialDelete, handleRadialUpdate } =
  useAnnotationHandlers(annotationLists)

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

watch(
  () => store.layout,
  () => {
    layoutButtonText.value = nextLayout().text
    if (!store.layout) {
      store.layout = LAYOUTS.PreviousFuture
    }
    localStorage.setItem(LAYOUT_STORAGE_KEY, store.layout)
  }
)

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

  let { leadId, leadItemsData, descriptorData } = useParamsSessionPop(
    {
      lead_id: 'leadId',
      otu_ids: 'leadItemsData',
      descriptor_data: 'descriptorData'
    },
    'interactive_key_to_key'
  )

  if (leadId) {
    // Call this for history.replaceState - it replaces turbolinks state
    // that would cause a reload every time we revisit this initial lead.
    setParam(RouteNames.NewLead, 'lead_id', leadId)
  }

  if (leadId && leadItemsData && descriptorData) {
    leadItemsData = JSON.parse(leadItemsData)
    descriptorData = JSON.parse(descriptorData)
    store.process_lead_items_data(leadItemsData, leadId).then(() => {
      store
        .loadKey(leadId)
        .then(() => store.process_descriptor_data(descriptorData))
    })
  } else if (leadId) {
    store.loadKey(leadId)
  }
})
</script>

<style scoped>
.meta {
  max-width: 1240px;
  margin: 0 auto;
}

.header-radials {
  margin-right: 0.5em;
}

.show-key-otus-lists {
  display: flex;
  flex-direction: row;
  align-items: start;
  justify-content: center;
  gap: 1rem;
}
</style>
