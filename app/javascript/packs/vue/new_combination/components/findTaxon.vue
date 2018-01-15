<template>
	<div class="find-taxonname-picker">
    <h2 v-if="rankLists.hasOwnProperty('genus') && !rankLists['genus'].length">Genus is not exist</h2>
    <list-group v-for="list, key in rankLists" :key="key" @onTaxonSelect="newCombination[key] = $event" :selected="newCombination[key]" :rank-name="key" :list="list" v-if="rankLists[key].length"></list-group>
    <button :disabled="!validateCreate()" class="button normal-input button-submit" @click="postCombination">Create</button>
 </div>
</template>

<script>

  import { GetParse, CreateCombination } from '../request/resources';
  import listGroup from './listGroup';

  export default {
    components: {
      listGroup
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
        newCombination: this.createNewCombination()
      }
    },
    watch: {
      taxonName(newVal) {
        this.$emit('onSearchStart', true);
        GetParse(newVal).then(response => {
          this.$emit('onSearchEnd', true);
          this.rankLists = response;
          this.fillWithUnique(response);
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
      postCombination() {
        let keys = Object.keys(this.newCombination);
        let combination = {}

        keys.forEach((rank) => {
          if(this.newCombination[rank]) {
            combination[`${rank}_id`] = this.newCombination[rank].id
          }
        })
        CreateCombination({ combination: combination }).then(response => { 
          console.log(response);
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