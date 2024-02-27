<template>
  <CornerSpinner :loading="store.loading" />
  <h1>{{ store.root.id ? 'Editing' : 'Create a new key' }}</h1>
  <!-- The back button on this link fails without data-turbolinks=false if the current url has an id param, but works fine if there's no id param. -->
  <p><a href="/leads/list" data-turbolinks="false">List of Keys</a></p>
  <BlockLayout expand class="meta">
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>Key metadata</h3>
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

  <PreviousCouplets v-if="store.lead.id" />
  <Couplet v-if="store.lead.id"/>
</template>

<script setup>
import { CITATION, DEPICTION } from '@/constants'
import { ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { useAnnotationHandlers } from './components/composables/useAnnotationHandlers.js'
import { usePopstateListener } from '@/compositions'
import { useStore } from './store/useStore'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import CornerSpinner from '../components/CornerSpinner.vue'
import Couplet from './components/Couplet.vue'
import PreviousCouplets from './components/PreviousCouplets.vue'
import KeyMeta from './components/KeyMeta.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import setParam from '@/helpers/setParam'

const store = useStore()

const depictions = ref([])
const citations = ref([])

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
  store.$reset()

  const { lead_id } = URLParamsToJSON(location.href)
  if (lead_id) {
    store.loadKey(lead_id)
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