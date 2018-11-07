<template>
  <div id="vue_new_combination">
    <h1>New combination</h1>
    <spinner
      legend="Loading new combination..."
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="loading"/>
    <div class="panel content new-combination-box separate-bottom">
      <input-search
        ref="inputSearch"
        placeholder="Type a new combination (names should already exist)."
        v-help.section.search.input
        @onTaxonName="setTaxon"/>
    </div>
    <new-combination
      class="separate-top"
      ref="combination"
      @save="resetInput(); addToList($event)"
      @onSearchStart="searching = true"
      @onSearchEnd="searching = false"
      :taxon-name="taxon"/>
    <h3 v-help.section.recent.overview>Recent</h3>
    <display-list
      :list="combinations"
      :edit="true"
      :annotator="true"
      @edit="editCombination"
      @delete="deleteCombination"
      @placement="updatePlacement"
      label="object_tag"/>
  </div>
</template>
<script>

import NewCombination from './components/newCombination.vue'
import InputSearch from './components/inputSearch.vue'
import DisplayList from './components/displayList.vue'
import Spinner from 'components/spinner.vue'

import { GetLastCombinations, DestroyCombination, GetCombination } from './request/resources'

export default {
  components: {
    DisplayList,
    NewCombination,
    InputSearch,
    Spinner
  },
  data: function () {
    return {
      searching: false,
      taxon: null,
      combinations: [],
      loading: false
    }
  },
  mounted: function () {
    this.loadCombination()
    TW.workbench.keyboard.createLegend(((navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + '+' + 's'), 'Save new combination', 'New combination')
    GetLastCombinations().then(response => {
      this.combinations = response
    })
  },
  methods: {
    setTaxon (event) {
      this.taxon = event
    },
    resetInput () {
      this.$refs.inputSearch.reset()
      this.$refs.inputSearch.focusInput()
    },
    editCombination (combination) {
      this.$refs.combination.editCombination(combination.name_string, combination)
      this.$refs.inputSearch.disabledButton(true)
    },
    addToList (combination) {
      let position = this.combinations.findIndex((item) => { return combination.id == item.id })

      if (position > -1) {
        this.$set(this.combinations, position, combination)
      } else {
        this.combinations.push(combination)
      }
    },
    updatePlacement (combination) {
      this.combinations[this.combinations.findIndex((item) => {
        return item.id == combination.id
      })].placement.same = true
    },
    deleteCombination (combination) {
      DestroyCombination(combination.id).then(() => {
        this.combinations.splice(this.combinations.findIndex((item) => {
          return item.id == combination.id
        }), 1)
        TW.workbench.alert.create('Combination was successfully deleted.', 'notice')
      })
    },
    loadCombination () {
      let urlParams = new URLSearchParams(window.location.search)
      let combinationId = urlParams.get('id')

      if (/^\d+$/.test(combinationId)) {
        this.loading = true
        GetCombination(combinationId).then(response => {
          this.editCombination(response)
          this.loading = false
        })
      }
    }
  }
}
</script>
<style lang="scss">
#vue_new_combination {
  flex-direction: column-reverse;
  margin: 0 auto;
  margin-top: 1em;
  max-width: 1240px;

  .cleft, .cright {
    min-width: 450px;
    max-width: 450px;
    width: 400px;
  }
  #cright-panel {
    width: 350px;
    max-width: 350px;
  }

  .new-combination-box {

    transition: all 1s;

    label {
      display: block;
    }

    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    .body {
      padding: 2em;
      padding-top: 1em;
      padding-bottom: 1em;
    }
    .taxonName-input,#error_explanation {
      width: 300px;
    }
  }
}
</style>
