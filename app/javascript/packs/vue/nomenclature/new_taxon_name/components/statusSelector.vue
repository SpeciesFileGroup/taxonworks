<template>
  <form class="content" v-if="rankClass">
    <h3>Status</h3>
    <div class="content flex-wrap-row">
      <ul class="flex-wrap-column no_bullets" v-for="itemsGroup in list.chunk(Math.ceil(list.length/4))">
        <li class="status-item" v-for="item in itemsGroup">
          <label><input type="radio" name="status-item" :value="item.type"/>{{ item.name }}</label>
        </li>
      </ul>
    </div>
  </form>
</template>
<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;  

  export default {
    computed: {
      statusList: {
        get() {
          return this.$store.getters[GetterNames.GetStatusList]
        },
        set(value) {
          this.$store.commit(MutationNames.SetStatusList, value);
        }
      },
      rankClass() {
        return this.$store.getters[GetterNames.GetRankClass]
      },
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      }
    },
    data: function() {
      return {
        list: []
      }
    },
    watch: {
      'rankClass': function(newVal, oldVal) {
        this.list = this.getStatusListForThisRank(this.statusList,newVal);
      }
    },
    methods: {
      getStatusListForThisRank(list, findStatus) {
        var 
        newList = [];
        list[this.parent.nomenclatural_code].forEach(function(item) {
          item['applicable_ranks'].find(status => {
            if(status == findStatus) {
              newList.push(item);
              return true
            }
          });
        });
        return newList;
      }
    }
  };
</script>