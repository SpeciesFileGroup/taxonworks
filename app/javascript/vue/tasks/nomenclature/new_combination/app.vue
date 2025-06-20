<template>
  <div id="vue_new_combination">
    <h1>New combination</h1>
    <div class="horizontal-left-content gap-small middle margin-small-bottom">
      <VIcon
        name="attention"
        color="attention"
        small
      />
      <i>At present this task is only configured for ICZN names.</i>
    </div>
    <VSpinner
      legend="Loading new combination..."
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px' }"
      v-if="loading"
    />
    <div class="panel content new-combination-box separate-bottom">
      <InputSearch
        ref="inputSearch"
        placeholder="Type a new combination (names should already exist)."
        v-help.section.search.input
        @onTaxonName="setTaxon"
      />
    </div>
    <NewCombination
      class="separate-top"
      ref="combination"
      @save="addToList"
      @onSearchStart="searching = true"
      @onSearchEnd="searching = false"
      :accept-taxon-ids="accept_taxon_name_id"
      :taxon-name="taxon"
    />
    <h3 v-help.section.recent.overview>Recent</h3>
    <DisplayList
      :list="combinations"
      @edit="editCombination"
      @delete="deleteCombination"
      @placement="updatePlacement"
    />
  </div>
</template>
<script>
import NewCombination from './components/newCombination.vue'
import InputSearch from './components/inputSearch.vue'
import DisplayList from './components/displayList.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { addToArray } from '@/helpers/arrays.js'
import { Combination, TaxonName } from '@/routes/endpoints'
import { EXTEND_PARAMS } from './constants/extend'

export default {
  components: {
    DisplayList,
    NewCombination,
    InputSearch,
    VSpinner,
    VIcon
  },

  data() {
    return {
      searching: false,
      taxon: null,
      combinations: [],
      loading: false,
      accept_taxon_name_id: []
    }
  },

  created() {
    this.loadCombination()

    Combination.all({ ...EXTEND_PARAMS }).then((response) => {
      this.combinations = response.body
    })

    TW.workbench.keyboard.createLegend(
      (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + '+' + 's',
      'Save new combination',
      'New combination'
    )
  },

  methods: {
    setTaxon(event) {
      this.accept_taxon_name_id = []
      this.taxon = event
    },

    resetInput() {
      this.$refs.inputSearch.reset()
      this.$refs.inputSearch.focusInput()
    },

    editCombination(combination) {
      const keys = Object.keys(combination.protonyms)

      this.accept_taxon_name_id = keys.map(
        (key) => combination.protonyms[key].id
      )
      this.$refs.combination.editCombination(
        combination.object_label,
        combination
      )
      this.$refs.inputSearch.disabledButton(true)
    },

    addToList(combination) {
      this.resetInput()
      addToArray(this.combinations, combination)
    },

    updatePlacement(combination) {
      this.combinations[
        this.combinations.findIndex((item) => item.id === combination.id)
      ].placement.same = true
    },

    deleteCombination(combination) {
      Combination.destroy(combination.id).then(() => {
        this.combinations.splice(
          this.combinations.findIndex((item) => item.id === combination.id),
          1
        )
        TW.workbench.alert.create(
          'Combination was successfully deleted.',
          'notice'
        )
      })
    },

    loadCombination() {
      const urlParams = new URLSearchParams(window.location.search)
      const combinationId =
        urlParams.get('id') ||
        urlParams.get('taxon_name_id') ||
        urlParams.get('combination_id')

      if (/^\d+$/.test(combinationId)) {
        this.loading = true
        Combination.find(combinationId, { ...EXTEND_PARAMS }).then(
          (response) => {
            const protonyms = Object.values(response.body.protonyms)
            this.accept_taxon_name_id = protonyms.map((taxon) => taxon.id)
            this.editCombination(response.body)
            this.loading = false
          },
          (_) => {
            history.pushState(null, null, window.location.href.split('?')[0])
            TaxonName.find(combinationId, { ...EXTEND_PARAMS })
              .then((response) => {
                this.$refs.inputSearch.processString(
                  `${response.body.parent.name} ${response.body.name}`
                )
                this.accept_taxon_name_id.push(response.body.id)
              })
              .finally((_) => {
                this.loading = false
              })
          }
        )
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

  .cleft,
  .cright {
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
    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;

    label {
      display: block;
    }

    .body {
      padding: 2em;
      padding-top: 1em;
      padding-bottom: 1em;
    }

    .taxonName-input,
    #error_explanation {
      width: 300px;
    }
  }
}
</style>
