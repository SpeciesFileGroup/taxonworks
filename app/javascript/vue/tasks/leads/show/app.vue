<template>
  <CornerSpinner :loading="loading" />

  <KeyList
    v-show="!lead_id"
    @load-couplet="loadCouplet"
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
    <PreviousCouplets
      :parents="parents"
      :root-text="root.text"
      @load-couplet="loadCouplet"
    />
    <Couplet
      :lead="lead"
      :left_expanded="left"
      :right_expanded="right"
      @load-couplet="loadCouplet"
    />
  </template>
</template>

<script setup>
import { Lead } from '@/routes/endpoints'
import { ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { usePopstateListener } from '@/compositions'
import CornerSpinner from './components/CornerSpinner.vue'
import Couplet from './components/Couplet.vue'
import Header from './components/Header.vue'
import KeyList from './components/KeyList.vue'
import PreviousCouplets from './components/PreviousCouplets.vue'
import setParam from '@/helpers/setParam'

const lead_id = ref(URLParamsToJSON(location.href).lead_id)

const root = ref({})
const lead = ref({})
const left = ref(makeExpandedLead())
const right = ref(makeExpandedLead())
const parents = ref([])

const loading = ref(false)

if (lead_id.value) {
  loadCouplet(lead_id.value)
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
    loadCouplet(lead_id.value)
  } else {
    reset()
  }
})

function makeExpandedLead() {
  return {
    lead: {},
    future: []
  }
}

function loadCouplet(id) {
  lead_id.value = id
  loading.value = true
  Lead.find(id, {extend: ['otu']})
    .then(({ body }) => {
      root.value = body.root
      lead.value = body.lead
      left.value.lead = body.left
      left.value.future = body.left_future
      right.value.lead = body.right
      right.value.future = body.right_future
      parents.value = body.parents
      setParam(RouteNames.ShowLead, 'lead_id', lead_id.value)
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
  left.value = makeExpandedLead()
  right.value = makeExpandedLead()
  parents.value = []
}
</script>

<style lang="scss" scoped>
.show_keys_list {
  margin-top: 2em;
}
</style>