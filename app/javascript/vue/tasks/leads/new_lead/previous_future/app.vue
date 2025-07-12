<template>
  <CornerSpinner :loading="store.loading" />
  <div class="flex-separate middle">
    <h1>
      {{ store.root.id ? 'Editing' : 'Create a new key' }}
    </h1>
    <slot name="layout"></slot>
  </div>
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
  <fieldset
    v-if="store.print_key"
    class="print-key"
  >
    <legend>Key Preview</legend>
    <div v-html="store.print_key" />
  </fieldset>
  <Couplet
    v-if="store.lead.id"
    @editing-has-occurred="() => (editingHasOccurred = true)"
  />
</template>

<script setup>
import { CITATION, DEPICTION } from '@/constants'
import { computed, onBeforeMount, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { useAnnotationHandlers } from './components/composables/useAnnotationHandlers.js'
import { usePopstateListener } from '@/composables'
import { useStore } from '../store/useStore.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import CornerSpinner from '../../components/CornerSpinner.vue'
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

// TODO Currently this is needed (why?) in the lead otu case where we have #id
// links in the v-html'ed html version of the key.
// LLM
onBeforeMount(() => {
  document.addEventListener('click', (e) => {
    const elt = e.target.closest("a[href^='#']");
    if (elt) {
      const id = elt.getAttribute('href').slice(1);
      const target = document.getElementById(id);
      if (target) {
        e.preventDefault(); // prevent full-page reload
        target.scrollIntoView({ behavior: 'smooth' });
      }
    }
  })
})
// END LLM

</script>

<style lang="scss" scoped>
.meta {
  max-width: 1240px;
  margin: 0 auto;
}

.header-radials {
  margin-right: .5em;
}

.print-key {
  width: 80vw;
  margin: 0 auto;
  border-top-left-radius: 0.9rem;
  border-bottom-left-radius: 0.9rem;
  padding-left: 2em;
  padding-right: 2em;
  height: 400px;
  overflow-y: scroll;
  margin-bottom: 1.5em;
  box-shadow: rgba(36, 37, 38, 0.08) 4px 4px 15px 0px;
  background-color: #fff;
}
</style>