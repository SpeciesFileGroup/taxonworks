<template>
  <ul class="tree-status">
    <li
      v-for="(item, key) in orderList"
      :key="key">
      <button
        v-if="item.hasOwnProperty(display)"
        type="button"
        :value="item.type"
        @click="selectItem(item)"
        :disabled="(item.disabled || (findExist(item) != undefined))"
        class="button button-default normal-input">
        {{ item[display] }}
      </button>
      <recursive-list
        :display="display"
        @selected="$emit('selected', $event)"
        :object-list="item"/>
    </li>
  </ul>
</template>

<script>
import RecursiveList from './recursiveList.vue'

export default {
  name: 'RecursiveList',

  components: { RecursiveList },

  props: {
    objectList: {
      type: Object,
      required: true
    },
    display: {
      type: String,
      required: true
    },
    created: {
      type: Array,
      default: () => []
    }
  },

  emits: ['selected'],

  computed: {
    orderList() {
      let sortable = []
      let sortableObject = {}

      for (var key in this.objectList) {
        sortable.push([key, this.objectList[key]])
      }

      sortable.sort((a, b) => {
        if (a[1][this.display] > b[1][this.display]) {
          return 1;
        }
        if (a[1][this.display] < b[1][this.display]) {
          return -1;
        }
        return 0;
      })

      sortable.forEach(item => {
        sortableObject[item[0]] = item[1]
      })

      return sortableObject
    }
  },

  methods: {
    selectItem (optionSelected) {
      this.$emit('selected', optionSelected)
    },

    findExist (item) {
      return this.created.find(element => element.type == item.type)
    },

    isForThisRank (item) {
      return item.valid_subject_ranks?.includes(this.taxon.rank_string)
    }
  }
}

</script>
<style lang="scss" scoped>
  .tree-status {
    list-style: none;
    li {
      margin-top: 6px;
      button:first-letter {
        text-transform: capitalize;
      }
    }
  }
</style>
