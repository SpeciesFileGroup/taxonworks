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
        :disabled="((item.disabled || !!alreadyCreated(item)) || isForThisRank(item))"
        class="button button-submit normal-input">
        {{ item[display] }}
      </button>
      <recursive-list
        v-if="isObject(item)"
        :created-list="createdList"
        :display="display"
        :valid-property="validProperty"
        :object-list="item"
        :taxon-rank="taxonRank"
        @selected="$emit('selected', $event)"
      />
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

    validProperty: {
      type: String,
      required: true
    },

    createdList: {
      type: Array,
      default: () => []
    },

    taxonRank: {
      type: String,
      required: true
    }
  },

  emits: ['selected'],

  computed: {
    orderList () {
      const sortable = []
      const sortableObject = {}

      for (const key in this.objectList) {
        sortable.push([key, this.objectList[key]])
      }

      sortable.sort((a, b) => {
        if (a[1][this.display] > b[1][this.display]) {
          return 1
        }
        if (a[1][this.display] < b[1][this.display]) {
          return -1
        }
        return 0
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

    alreadyCreated (status) {
      return this.createdList.find(element => element.type === status.type)
    },

    isForThisRank (item) {
      return item[this.validProperty] && !(item[this.validProperty].includes(this.taxonRank))
    },

    isObject (item) {
      return typeof item === 'object'
    }
  }
}

</script>
