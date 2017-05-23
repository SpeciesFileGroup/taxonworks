<template>

  <form class="content" v-if="rankClass">
    <modal v-if="showModal" @close="showModal = false">
      <h3 slot="header">Status</h3>
      <div slot="body" class="tree-list">
        <recursive-list :objectList="tree"></recursive-list>
      </div>
    </modal>
    <h3>Status</h3>
    <button type="button" @click="showAdvance = false">Common</button>
    <button @click="showAdvance = true" type="button">Advanced</button>
    <button @click="showModal = true" type="button">Show all</button>
    <div>
      <autocomplete v-if="showAdvance"
        :arrayList="allList"
        label="name"
        min="3"
        time="0"
        eventSend="parentSelected"
        param="term">
      </autocomplete>    
      <div v-else class="content flex-wrap-row">
        <ul class="flex-wrap-column no_bullets">
          <li class="status-item" v-for="item in commonList">
            <label><input type="radio" name="status-item" :value="item.type"/>{{ item.name }}</label>
          </li>
        </ul>
      </div>
    </div>
  </form>
</template>
<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;  
  const autocomplete = require('../../../components/autocomplete.vue');
  const recursiveList = require('./recursiveList.vue');
  const modal = require('../../../components/modal.vue');

  export default {
    components: {
      autocomplete,
      recursiveList,
      modal
    },
    computed: {
      rankClass() {
        return this.$store.getters[GetterNames.GetRankClass]
      },
      statusList: {
        get() {
          return this.$store.getters[GetterNames.GetStatusList]
        },
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      }
    },
    data: function() {
      return {
        allList: [],
        commonList: [],
        tree: undefined,
        showAdvance: false,
        showModal: false,
      }
    },
    watch: {
      'parent': function(newVal, oldVal) {
        this.tree = Object.assign({}, this.statusList[this.parent.nomenclatural_code].tree);
        
        this.getStatusListForThisRank(this.statusList[this.parent.nomenclatural_code].all,this.parent.rank_string).then( resolve => {
          this.allList = resolve;
          this.getTreeListForThisRank(this.tree, this.statusList[this.parent.nomenclatural_code].all, resolve);
        });
        this.getStatusListForThisRank(this.statusList[this.parent.nomenclatural_code].common,this.parent.rank_string).then( resolve => {
          this.commonList = resolve;
        });
      }
    },
    mounted: function() {
      var that = this;
      this.$on('closeModal', function () {
        that.showModal = false;
      }) 
    },
    methods: {
      getStatusListForThisRank(list, findStatus) {
        return new Promise(function (resolve, reject) {
          var 
          newList = [];

          for (var key in list) {
            var t = list[key].applicable_ranks;
            t.find(function (item) {
              if(item == findStatus) {
                newList.push(list[key]);
                return true
              }
            });
          };
        resolve(newList);
        });
      },
      getTreeListForThisRank(list, ranksList, filteredList) {
        for(var key in list) {
            Object.defineProperty(list[key], 'name', { value: ranksList[key].name });
            Object.defineProperty(list[key], 'type', { value: ranksList[key].type });

            if(filteredList.find(function(item) {
              if(item.type == key) {
                return true;
              }
            })) {
              Object.defineProperty(list[key], 'disabled', { value: false });
            }
            else {
              Object.defineProperty(list[key], 'disabled', { value: true });
            }

            this.getTreeListForThisRank(list[key], ranksList, filteredList);
        }
      }
    }
  };
</script>