<template>
	<div class="find-taxonname-picker">
    <spinner 
      legend="Saving new combination..." 
      :full-screen="true" 
      :logo-size="{ width: '100px', height: '100px'}" 
      v-if="saving">
    </spinner>
    <spinner 
      legend="Searching taxon names..." 
      :legend-style="{ fontSize: '14px', color: '#444', textAlign: 'center', paddingTop: '20px'}" 
      v-if="searching">
    </spinner>
    <div class="panel new-combination-box" v-if="Object.keys(rankLists).length">

        <div class="header flex-separate middle" :class="{ 'header-warning': !(rankLists['genus'] && rankLists['genus'].length) }">
          <h3>Combination</h3>
        </div>

        <div>
          <div v-if="!isCombinationEmpty()">
            <preview-view 
              :combination="newCombination.protonyms"></preview-view>
          </div>
          
          <div class="flexbox">
            <list-group 
              class="item"                
              v-for="list, key in rankLists" 
              :key="key"
              ref="listGroup"
              @onTaxonSelect="newCombination.protonyms[key] = $event" 
              :selected="newCombination.protonyms[key]" 
              :rank-name="key" 
              :parseString="parseRanks[key]"
              :list="list"
              v-if="parseRanks[key]">
            </list-group>
          </div>
          <hr/>
          <div class="content">
            <source-picker
              :citation="newCombination['origin_citation']"
              @select="setSource">
            </source-picker>
          </div>

          <div class="content">
            <save-combination 
              @success="reset()"
              @processing="saving = $event" 
              @save="setSavedCombination($event)" 
              ref="saveButton"
              :new-combination="newCombination">
            </save-combination>
            <button 
              class="normal-input button button-default" 
              @click="expandAll()" 
              :disabled="enableEdit"
              tabindex="-1" 
              type="button"><span data-icon="reset">Edit</span>
            </button>
          </div>
        </div>

    </div>
  </div>
</template>

<script>

  import { GetParse } from '../request/resources';
  import listGroup from './listGroup.vue';
  import saveCombination from './saveCombination.vue';
  import previewView from './previewView.vue';
  import sourcePicker from './sourcePicker.vue';
  import spinner from '../../components/spinner.vue';

  export default {
    components: {
      listGroup,
      sourcePicker,
      saveCombination,
      previewView,
      spinner
    },
    props: {
      taxonName: {
        required: true
      },
      combination: {
        type: Object
      }
    },
    computed: {
      enableEdit() {
        return (Object.keys(this.rankLists).find((rank) => {
          return this.rankLists[rank] && this.rankLists[rank].length > 1 
        }) == undefined ? true : false)
      }
    },
    data: function() {
      return {
        rankLists: {},
        parseRanks: {},
        searching: false,
        saving: false,
        newCombination: this.createNewCombination()
      }
    },
    watch: {
      taxonName(newVal) {
        this.newCombination = this.createNewCombination();
        if(newVal) {
          this.setRankList(newVal);
        }
        else {
          this.rankLists = {};
        }
      }
    },
    methods: {
      reset() {
        this.newCombination = this.createNewCombination();
        this.rankLists = {};
        this.parseRanks = {};
      },
      setRankList(literalString) {
        this.$emit('onSearchStart', true);
        this.searching = true;
        GetParse(literalString).then(response => {
          this.$emit('onSearchEnd', true);
          this.rankLists = response.data.protonyms;
          this.parseRanks = response.data.parse;
          this.searching = false;
          this.$nextTick(() => {
            if(response.data.unambiguous) {
              this.$refs.saveButton.setFocus();
            }
          })
        })
      },
      editCombination(literalString, combination) {
        this.newCombination = combination;
        this.setRankList(literalString);
      },
      expandAll() {
        this.$refs.listGroup.forEach(component => {
          component.expandList();
        })
      },
      setSavedCombination(combination) {
        this.$emit('save', combination);
        this.setNewCombination(combination);
      },
      setNewCombination(combination) {
        let newCombination = Object.assign({}, { id: combination.id }, { origin_citation: (combination['origin_citation'] ? combination.origin_citation : undefined)}, { protonyms: combination.protonyms })
        this.newCombination = newCombination;
      },
      createNewCombination() {
        return {
          protonyms: {
            subspecies: undefined,
            species: undefined,
            subgenus: undefined,
            genus: undefined
          }
        }
      },
      setSource(citation) {
        this.newCombination = Object.assign(this.newCombination, citation)
      },
      isCombinationEmpty() {
        let found = false;

        for (var rank in this.newCombination.protonyms) {
          if(this.newCombination.protonyms[rank]) {
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