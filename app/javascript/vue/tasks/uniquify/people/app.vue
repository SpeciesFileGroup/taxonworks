<template>
  <div id="vue-people-uniquify">
    <div class="flex-separate middle">
      <h1>Uniquify people</h1>
      <SettingsNavbar @reset="resetApp" />
    </div>

    <URLComponent v-show="settings.activeJSONRequest" />

    <div class="horizontal-left-content align-start">
      <FilterPanel
        v-show="settings.showSearch"
        ref="filterPanel"
        :disabled-match="!selectedPerson.id"
        @find-people="findPeople"
        @match-people="getMatchPeople"
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
      :logo-size="{ width: '100px', height: '100px'}"
    />
  </div>
</template>

<script>

import SettingsNavbar from './components/SettingsNavbar.vue'
import FilterPanel from './components/Filter/FilterPanel.vue'
import FoundPeople from './components/FoundPeople'
import MatchPeople from './components/MatchPeople'
import CompareTable from './components/CompareTable.vue'
import VSpinner from 'components/spinner.vue'
import URLComponent from './components/URLComponent.vue'

import { ActionNames } from './store/actions/actions'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'

export default {
  name: 'UniquifyPeople',

  components: {
    CompareTable,
    FilterPanel,
    FoundPeople,
    MatchPeople,
    SettingsNavbar,
    URLComponent,
    VSpinner
  },

  computed: {
    selectedPerson: {
      get () {
        return this.$store.getters[GetterNames.GetSelectedPerson]
      },

      set (value) {
        this.$store.commit(MutationNames.SetSelectedPerson, value)
      }
    },

    mergeList: {
      get () {
        return this.$store.getters[GetterNames.GetMergePeople]
      },

      set (value) {
        this.$store.commit(MutationNames.SetMergePeople, value)
      }
    },

    settings () {
      return this.$store.getters[GetterNames.GetSettings]
    },

    requestState () {
      return this.$store.getters[GetterNames.GetRequestState]
    },

    spinnerMessage () {
      return this.requestState.isLoading
        ? 'Loading...'
        : `Merging... ${this.mergeList.length} persons remaining...`
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const lastName = urlParams.get('last_name')
    const personId = urlParams.get('person_id')

    if (/^\d+$/.test(personId)) {
      this.getPerson(personId)
    } else if (lastName) {
      this.findPerson({ last_name: lastName })
    }
  },

  methods: {
    findPeople (params) {
      this.$store.dispatch(ActionNames.FindPeople, params)
    },

    getMatchPeople (params) {
      this.$store.dispatch(ActionNames.FindMatchPeople, params)
    },

    getPerson (id) {
      this.$store.dispatch(ActionNames.AddSelectPerson, id)
    },

    resetApp () {
      this.$refs.filterPanel.resetFilter()
      this.$store.dispatch(ActionNames.ResetStore)
    }
  }
}
</script>

<style lang="scss">
#vue-people-uniquify {
  .merge-column {
    width: 150px;
  }

  .feedback {
    line-height: 2.5 !important;
  }
}

</style>
