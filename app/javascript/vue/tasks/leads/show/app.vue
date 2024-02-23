<template>
  <h1>{{ lead_id? 'Couplets' : 'Available Keys' }}</h1>
  <KeyList v-if="!lead_id" />
</template>

<script setup>
import { ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { usePopstateListener } from '@/compositions'
import KeyList from './components/KeyList.vue'
import setParam from '@/helpers/setParam'

const lead_id = ref(URLParamsToJSON(location.href).lead_id)

if (lead_id.value) {
  // Call this for history.replaceState - it replaces turbolinks state
  // that would cause a reload every time we revisit this initial lead.
  // TODO: shouldn't we do this if there's not an id as well?
  setParam(RouteNames.ShowLead, 'lead_id', lead_id.value)
  loadCouplet(lead_id.value)
}
else {
  reset()
}

usePopstateListener(() => {
  reset()

  lead_id.value = URLParamsToJSON(location.href)
  if (lead_id.value) {
    loadCouplet(lead_id.value)
  }
})

function loadCouplet(id) {

}

function reset() {
  lead_id.value = null
}
</script>