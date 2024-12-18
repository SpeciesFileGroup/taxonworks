<template>
  <CornerSpinner :loading="store.loading" />
  <h1>{{ store.root.id ? 'Editing' : 'Create a new key' }}</h1>
  <p>
    <a
      :href="RouteNames.LeadsHub"
      data-turbolinks="false"
    >
      Multifurcating Keys Hub
    </a>
  </p>
  <BlockLayout
    expand
    :set-expanded="!editingHasOccurred"
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

  <PreviousLeads v-if="store.lead.id" />
  <Couplet
    v-if="store.lead.id"
    @editing-has-occurred="() => (editingHasOccurred = true)"
  />
</template>

<script setup>
import { CITATION, DEPICTION } from '@/constants'
import { computed, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { useAnnotationHandlers } from './components/composables/useAnnotationHandlers.js'
import { usePopstateListener } from '@/composables'
import { useStore } from './store/useStore'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import CornerSpinner from '../components/CornerSpinner.vue'
import Couplet from './components/Couplet.vue'
import PreviousLeads from './components/PreviousLeads.vue'
import KeyMeta from './components/KeyMeta.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import setParam from '@/helpers/setParam'

const store = useStore()

const depictions = ref([])
const citations = ref([])

const metaExpanded = ref(true)
const editingHasOccurred = ref(false)

const metadataTitle = computed(() => {
  const defaultText = 'Key metadata'
  if (metaExpanded.value || !store.root.text) {
    return defaultText
  } else {
    return defaultText + ' - ' + store.root.text
  }
})

const annotationLists = {
  [DEPICTION]: depictions,
  [CITATION]: citations
}
const {
  handleRadialCreate,
  handleRadialDelete,
  handleRadialUpdate
} = useAnnotationHandlers(annotationLists)

const { lead_id } = URLParamsToJSON(location.href)

if (lead_id) {
  // Call this for history.replaceState - it replaces turbolinks state
  // that would cause a reload every time we revisit this initial lead.
  setParam(RouteNames.NewLead, 'lead_id', lead_id)
  store.loadKey(lead_id)
}

usePopstateListener(() => {
  const { lead_id } = URLParamsToJSON(location.href)
  if (lead_id) {
    store.loadKey(lead_id)
  } else {
    store.$reset()
  }
})
</script>

<style lang="scss" scoped>
.meta {
  max-width: 1240px;
  margin: 0 auto;
}
.header-radials {
  margin-right: .5em;
}
</style>