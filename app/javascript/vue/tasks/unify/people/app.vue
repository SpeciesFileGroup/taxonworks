<template>
  <div id="vue-people-unify">
    <div class="flex-separate middle">
      <h1>Unify people</h1>
      <SettingsNavbar @reset="resetApp" />
    </div>

    <URLComponent v-show="settings.activeJSONRequest" />

    <div class="horizontal-left-content align-start">
      <FilterPanel
        v-show="settings.showSearch"
        ref="filterPanel"
        :disabled-match="!selectedPerson.id"
        v-model="params"
        @find-people="
          () =>
            store.dispatch(
              ActionNames.FindPeople,
              removeEmptyParameters(params)
            )
        "
        @match-people="
          () =>
            store.dispatch(
              ActionNames.FindMatchPeople,
              removeEmptyParameters(params)
            )
        "
      />
      <div class="full_width horizontal-left-content align-start">
        <div class="margin-medium-right margin-medium-left">
          <FoundPeople
            v-show="settings.showFound"
            ref="foundPeople"
          />
          <MatchPeople
            v-show="settings.showMatch"
            v-model="mergeList"
            :selected-person="selectedPerson"
          />
        </div>
        <div class="flex-separate top">
          <div>
            <compare-table
              :selected="selectedPerson"
              :merge-list="mergeList"
            />
          </div>
        </div>
      </div>
    </div>

    <VSpinner
      v-if="requestState.isLoading || requestState.isMerging"
      full-screen
      :legend="spinnerMessage"
      :logo-size="{ width: '100px', height: '100px' }"
    />
  </div>
</template>

<script setup>
import SettingsNavbar from './components/SettingsNavbar.vue'
import FilterPanel from './components/Filter/FilterPanel.vue'
import FoundPeople from './components/FoundPeople'
import MatchPeople from './components/MatchPeople'
import CompareTable from './components/CompareTable.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import URLComponent from './components/URLComponent.vue'

import { ActionNames } from './store/actions/actions'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { useStore } from 'vuex'
import { computed, ref, onBeforeMount } from 'vue'

defineOptions({
  name: 'UnifyPeople'
})

const store = useStore()
const params = ref({})

const selectedPerson = computed({
  get() {
    return store.getters[GetterNames.GetSelectedPerson]
  },

  set(value) {
    store.commit(MutationNames.SetSelectedPerson, value)
  }
})

const mergeList = computed({
  get() {
    return store.getters[GetterNames.GetMergePeople]
  },

  set(value) {
    store.commit(MutationNames.SetMergePeople, value)
  }
})

const settings = computed(() => store.getters[GetterNames.GetSettings])
const requestState = computed(() => store.getters[GetterNames.GetRequestState])

const spinnerMessage = computed(() =>
  requestState.value.isLoading
    ? 'Loading...'
    : `Merging... ${mergeList.value.length} persons remaining...`
)

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const personId = urlParams.get('person_id')

  if (/^\d+$/.test(personId)) {
    getPerson(personId)
  }
})

function removeEmptyParameters(params) {
  const cleanedParameters = { ...params }

  for (const key in params) {
    const value = params[key]

    if (
      value === undefined ||
      value === '' ||
      (Array.isArray(value) && !value.length)
    ) {
      delete cleanedParameters[key]
    }
  }

  return cleanedParameters
}

function getPerson(id) {
  store.dispatch(ActionNames.AddSelectPerson, id)
}

function resetApp() {
  params.value = {}
  store.dispatch(ActionNames.ResetStore)
}
</script>

<style lang="scss">
#vue-people-unify {
  .merge-column {
    width: 150px;
  }

  .feedback {
    line-height: 2.5 !important;
  }
}
</style>
