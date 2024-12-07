<template>
  <CornerSpinner :loading="loading" />

  <KeyList
    v-show="!lead_id"
    @load-key="(key_id) => loadLead(key_id)"
  />

  <div
    v-if="lead_id"
    class="show_keys_list"
  >
    <span
      class="link cursor-pointer"
      @click="showKeyList"
    >
      List of Keys
    </span>
  </div>

  <template v-if="root.id">
    <Header :root="root" />
    <PreviousLeads
      :ancestors="ancestors"
      :lead="lead"
      :root-text="root.text"
      @load-lead="(id) => loadLead(id)"
    />
    <OptionSet
      :lead="lead"
      :option-set="optionSet"
      :futures="futures"
      @load-lead="(id) => loadLead(id)"
    />
  </template>
</template>

<script setup>
import { Lead } from '@/routes/endpoints'
import { ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { usePopstateListener } from '@/composables'
import CornerSpinner from '../components/CornerSpinner.vue'
import OptionSet from './components/OptionSet.vue'
import Header from './components/Header.vue'
import KeyList from './components/KeyList.vue'
import PreviousLeads from './components/PreviousLeads.vue'
import setParam from '@/helpers/setParam'

const lead_id = ref(URLParamsToJSON(location.href).lead_id)

const root = ref({})
const lead = ref({})
const optionSet = ref([])
const futures = ref([])
const ancestors = ref([])

const loading = ref(false)

if (lead_id.value) {
  loadLead(lead_id.value)
  // Call this for history.replaceState - it replaces turbolinks state
  // that would cause a reload every time we revisit this initial lead.
  setParam(RouteNames.ShowLead, 'lead_id', lead_id.value)
} else {
  setParam(RouteNames.ShowLead, 'lead_id')
  reset()
}

usePopstateListener(() => {
  lead_id.value = URLParamsToJSON(location.href).lead_id
  if (lead_id.value) {
    loadLead(lead_id.value)
  } else {
    reset()
  }
})

function loadLead(id) {
  lead_id.value = id
  loading.value = true
  Lead.find(id, { extend: ['otu', 'future_otus'] })
    .then(({ body }) => {
      root.value = body.root
      lead.value = body.lead
      optionSet.value = body.children
      futures.value = body.futures
      ancestors.value = body.ancestors
      setParam(RouteNames.ShowLead, 'lead_id', lead_id.value)
    })
    .catch(() => {
      TW.workbench.alert.create('Unable to load the requested id.', 'error')
      showKeyList()
    })
    .finally(() => {
      loading.value = false
    })
}

function showKeyList() {
  reset()
  setParam(RouteNames.ShowLead, 'lead_id')
}

function reset() {
  lead_id.value = null
  root.value = {}
  lead.value = {}
  optionSet.value = []
  futures.value = []
  ancestors.value = []
}
</script>

<style lang="scss" scoped>
.show_keys_list {
  margin-top: 2em;
}
</style>