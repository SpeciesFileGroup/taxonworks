<template>
  <div class="find-taxonname-picker">
    <spinner
      legend="Saving new combination..."
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="saving"/>
    <spinner
      legend="Searching taxon names..."
      :legend-style="{ fontSize: '14px', color: '#444', textAlign: 'center', paddingTop: '20px'}"
      v-if="searching"/>
    <div
      class="panel new-combination-box separate-bottom"
      v-if="Object.keys(rankLists).length">

      <div
        class="header flex-separate middle"
        :class="{ 'header-warning': !(rankLists['genus'] && rankLists['genus'].length) }">
        <h3>Combination</h3>
      </div>

      <div>
        <div v-if="!isCombinationEmpty()">
          <preview-view
            @onVerbatimChange="newCombination.verbatim_name = $event"
            :combination="newCombination"
            :incomplete="incompleteMatch"/>
        </div>

        <div class="flexbox">
          <list-group
            class="item1"
            v-for="(list, key) in rankLists"
            :key="key"
            ref="listGroup"
            @onTaxonSelect="newCombination.protonyms[key] = $event"
            @addToList="addTaxonToList"
            :selected="newCombination.protonyms[key]"
            :rank-name="key"
            :parse-string="parseRanks[key]"
            :accept-taxon-ids="acceptTaxonIds"
            :list="list"
            v-if="parseRanks[key]"/>
        </div>
        <hr>
        <div class="content">
          <source-picker
            :citation="newCombination['origin_citation']"
            @select="setSource"/>
        </div>

        <div class="content">
          <save-combination
            @success="reset()"
            @processing="saving = $event"
            @save="setSavedCombination($event)"
            ref="saveButton"
            :new-combination="newCombination"/>
          <button
            class="normal-input button button-default"
            @click="expandAll()"
            tabindex="-1"
            type="button"><span data-icon="reset">Unlock</span>
          </button>
        </div>
      </div>
    </div>

    <div
      class="panel new-combination-box separate-top"
      v-if="existMatches">
      <div
        class="header flex-separate middle">
        <h3>Other matches</h3>
      </div>
      <div class="flexbox">
        <match-group
          v-for="(list, key) in otherMatches"
          v-if="list.length"
          :key="key"
          :rank-name="key"
          :list="list"/>
      </div>
    </div>

  </div>
</template>

<script>

import ListGroup from './listGroup.vue'
import SaveCombination from './saveCombination.vue'
import PreviewView from './previewView.vue'
import SourcePicker from './sourcePicker.vue'
import Spinner from 'components/spinner.vue'
import MatchGroup from './matchGroup.vue'
import { Combination, TaxonName } from 'routes/endpoints'

export default {
  components: {
    MatchGroup,
    ListGroup,
    SourcePicker,
    SaveCombination,
    PreviewView,
    Spinner
  },
  props: {
    taxonName: {
      required: true
    },
    combination: {
      type: Object
    },
    acceptTaxonIds: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    enableEdit () {
      return (Object.keys(this.rankLists).find((rank) => {
        return this.rankLists[rank] && this.rankLists[rank].length > 1
      }) == undefined)
    },
    existMatches () {
      for(var key in this.otherMatches) {
        if(this.otherMatches[key].length) {
          return true
        }
      }
      return false
    },
    incompleteMatch () {
      const ranks = Object.entries(this.parseRanks).filter(([key, value]) => value).map(([key, value]) => key)
      return !!ranks.find(rank => !this.newCombination.protonyms[rank])
    }
  },
  data: function () {
    return {
      rankLists: {},
      parseRanks: {},
      otherMatches: {},
      searching: false,
      saving: false,
      newCombination: this.createNewCombination()
    }
  },
  watch: {
    taxonName (newVal) {
      this.newCombination = this.createNewCombination()
      this.otherMatches = {}
      if (newVal) {
        this.setRankList(newVal).then(response => {
          if (response.body.data.existing_combination_id) {
            Combination.find(response.body.data.existing_combination_id).then(response => {
              this.newCombination = response.body
            })
          }
        })
      } else {
        this.rankLists = {}
      }
    }
  },
  methods: {
    reset () {
      this.otherMatches = []
      this.newCombination = this.createNewCombination()
      this.rankLists = {}
      this.parseRanks = {}
    },
    setRankList (literalString, combination = undefined) {
      return new Promise((resolve, reject) => {
        this.$emit('onSearchStart', true)
        this.searching = true
        TaxonName.parse({ query_string: literalString }).then(response => {
          if (combination) {
            const ranks = Object.keys(combination.protonyms)
            ranks.forEach(rank => {
              const protonym = combination.protonyms[rank]
              if (!response.body.data.protonyms[rank].find(item => item.id === protonym.id)) {
                response.body.data.protonyms[rank].push(protonym)
              }
            })
          }
          this.rankLists = response.body.data.protonyms
          this.parseRanks = response.body.data.parse
          this.searching = false
          this.otherMatches = response.body.other_matches
          this.$emit('onSearchEnd', true)
          this.$nextTick(() => {
            if (response.body.data.unambiguous) {
              this.$refs.saveButton.setFocus()
            }
          })
          return resolve(response)
        })
      })
    },
    addTaxonToList(event) {
      this.rankLists[event.rank].push(event.taxon)
    },
    editCombination (literalString, combination) {
      this.newCombination = combination
      this.setRankList(literalString, combination)
    },
    expandAll () {
      this.$refs.listGroup.forEach(component => {
        component.expandList()
      })
    },
    setSavedCombination (combination) {
      this.$emit('save', combination)
      this.setNewCombination(combination)
    },
    setNewCombination (combination) {
      let newCombination = Object.assign({}, 
        { id: combination.id }, 
        { origin_citation: (combination['origin_citation'] ? combination.origin_citation : undefined)}, 
        { protonyms: combination.protonyms },
        { verbatim_name: combination.verbatim_name })
      this.newCombination = newCombination
    },
    createNewCombination () {
      return {
        verbatim_name: undefined,
        protonyms: {
          subspecies: undefined,
          species: undefined,
          subgenus: undefined,
          genus: undefined
        }
      }
    },
    setSource (citation) {
      this.newCombination = Object.assign(this.newCombination, citation)
    },
    isCombinationEmpty () {
      for (var rank in this.newCombination.protonyms) {
        if (this.newCombination.protonyms[rank]) {
          return false
        }
      }
      return true
    }
  }
}
</script>
<style scoped>
  .create-new-combination {
    min-width: 100px;
  }
  .header {
    padding: 1em;
    padding-left: 1.5em;
    border-bottom: 1px solid #f5f5f5;
    border-left:4px solid green;
    h3 {
      font-weight: 300;
    }
  }
  .header-warning {
    border-left: 4px solid #ff8c00 !important;
  }
  hr {
    height: 1px;
    color: #f5f5f5;
    background: #f5f5f5;
    font-size: 0;
    margin: 15px;
    border: 0;
  }
</style>
