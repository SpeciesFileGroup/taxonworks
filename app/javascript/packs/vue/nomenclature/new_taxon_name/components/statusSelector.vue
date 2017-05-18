<template>
  <form class="content" v-if="rankClass">
    <h3>Status</h3>
    <button type="button" @click="showAdvance = false">Common</button><button @click="showAdvance = true" type="button">Advance</button>
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

  export default {
    components: {
      autocomplete
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
        showAdvance: false
      }
    },
    watch: {
      'parent': function(newVal, oldVal) {
        this.allList = this.getStatusListForThisRank(this.statusList[this.parent.nomenclatural_code].all,this.parent.rank_string);
        this.commonList = this.getStatusListForThisRank(this.statusList[this.parent.nomenclatural_code].common,this.parent.rank_string);
      }
    },
    methods: {
      getStatusListForThisRank(list, findStatus) {
        var 
        newList = [];

        for (var key in list) {
          var t = list[key].applicable_ranks;
          t.find(function (item) {

            if(item == findStatus) {
              console.log(item);
              newList.push(list[key]);
              return true
            }
          });
        };
        return newList;
      }
    }
  };
</script>