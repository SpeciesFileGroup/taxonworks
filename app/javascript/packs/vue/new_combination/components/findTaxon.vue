<template>
	<div class="find-taxonname-picker">
    <div class="flexbox">
      <div class="panel item new-combination-box separate-right">
        <spinner legend="Searching taxon names..." :legend-style="{ fontSize: '14px', color: '#444', textAlign: 'center', paddingTop: '20px'}" v-if="searching"></spinner>
        <template v-if="rankLists.hasOwnProperty('genus')">

          <div class="header flex-separate middle" :class="{ 'header-warning': !rankLists['genus'].length }">
            <h3>Combination</h3>
          </div>

          <div class="horizontal-center-content content" v-if="!rankLists['genus'].length">
            <h3>Genus not found</h3>
          </div>

          <div v-else>
            <list-group v-for="list, key in rankLists" :key="key" @onTaxonSelect="newCombination[key] = $event" :selected="newCombination[key]" :rank-name="key" :list="list" v-if="rankLists[key].length"></list-group>
            <div class="content">
              <button :disabled="!validateCreate()" class="button normal-input button-submit create-new-combination" @click="postCombination">Create</button>
            </div>
          </div>

        </template>
        <div v-else class="horizontal-center-content content">
          <h3>Write something to start the new combination</h3>
        </div>
      </div>
      <div v-if="!isCombinationEmpty()" class="preview panel item new-combination-box cright separate-left">
        <preview-view :combination="newCombination"></preview-view>
      </div>
    </div>
  </div>
</template>

<script>

  import { GetParse, CreateCombination } from '../request/resources';
  import listGroup from './listGroup.vue';
  import previewView from './previewView.vue';
  import spinner from '../../components/spinner.vue';

  export default {
    components: {
      listGroup,
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
        newCombination: this.createNewCombination()
      }
    },
    watch: {
      taxonName(newVal) {
        this.$emit('onSearchStart', true);
        this.searching = true;
        this.newCombination = this.createNewCombination();
        GetParse(newVal).then(response => {
          this.$emit('onSearchEnd', true);
          this.rankLists = response;
          this.fillWithUnique(response);
          this.searching = false;
        })
      }
    },
    methods: {
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
            console.log(this.newCombination[rank]);
            return false
          }
        }
        return true
      },
      postCombination() {
        let keys = Object.keys(this.newCombination);
        let combination = {}

        keys.forEach((rank) => {
          if(this.newCombination[rank]) {
            combination[`${rank}_id`] = this.newCombination[rank].id
          }
        })
        CreateCombination({ combination: combination }).then(response => { 
          TW.workbench.alert.create('New combination was successfully created.', 'notice');
        });
      },
      validateCreate() {
        return (this.newCombination.genus && this.newCombination.species)
      },
      fillWithUnique(list) {
        let keys = Object.keys(list);
        let that = this;

        keys.forEach((key) => {
          if(list[key].length == 1) {
            that.newCombination[key] = list[key][0]
          }
        })
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