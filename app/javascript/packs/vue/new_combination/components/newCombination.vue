<template>
	<div class="find-taxonname-picker">
    <spinner legend="Saving new combination..." :full-screen="true" :logo-size="{ width: '100px', height: '100px'}" v-if="saving"></spinner>

    <div class="flexbox">
      <div class="panel item new-combination-box">
        <spinner legend="Searching taxon names..." :legend-style="{ fontSize: '14px', color: '#444', textAlign: 'center', paddingTop: '20px'}" v-if="searching"></spinner>

        <template v-if="rankLists.hasOwnProperty('genus')">
          <div class="header flex-separate middle" :class="{ 'header-warning': !rankLists['genus'].length }">
            <h3>Combination</h3>
          </div>

          <div v-if="!rankLists['genus'].length" class="horizontal-center-content content">
            <h3>Genus not found</h3>
          </div>

          <div v-else>

            <div v-if="!isCombinationEmpty()">
              <preview-view 
                @edit="expandAll()" 
                :combination="newCombination"></preview-view>
            </div>
          
            <div class="flexbox">
              <list-group 
                class="item"                
                v-for="list, key in rankLists" 
                :key="key"
                ref="listGroup"
                @onTaxonSelect="newCombination[key] = $event" 
                :selected="newCombination[key]" 
                :rank-name="key" 
                :list="list"
                v-if="list.length">
              </list-group>
            </div>

            <div class="content">
              <save-combination 
                @success="reset()"
                @processing="saving = $event" 
                @save="setNewCombination($event)" 
                :new-combination="newCombination">
              </save-combination>
            </div>

          </div>
        </template>

      </div>
    </div>

  </div>
</template>

<script>

  import { GetParse } from '../request/resources';
  import listGroup from './listGroup.vue';
  import saveCombination from './saveCombination.vue';
  import previewView from './previewView.vue';
  import spinner from '../../components/spinner.vue';

  export default {
    components: {
      listGroup,
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
    data: function() {
      return {
        rankLists: {},
        searching: false,
        saving: false,
        newCombination: this.createNewCombination()
      }
    },
    watch: {
      taxonName(newVal) {
        this.newCombination = this.createNewCombination();
        if(newVal) {
          this.$emit('onSearchStart', true);
          this.searching = true;
          GetParse(newVal).then(response => {
            this.$emit('onSearchEnd', true);
            this.rankLists = response;
            this.searching = false;
          })
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
      },
      expandAll() {
        this.$refs.listGroup.forEach(component => {
          component.expandList();
        })
      },
      setNewCombination(combination) {
        this.newCombination = combination;
      },
      createNewCombination() {
        return {
          genus: undefined,
          subgenus: undefined,
          species: undefined,
          subspecies: undefined
        }
      },
      isCombinationEmpty() {
        let found = false;

        for (var rank in this.newCombination) {
          if(this.newCombination[rank]) {
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
</style>