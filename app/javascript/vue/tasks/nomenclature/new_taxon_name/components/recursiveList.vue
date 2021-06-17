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
        :disabled="((item.disabled || (findExist(item) != undefined)) || isForThisRank(item))"
        class="button button-submit normal-input">
        {{ item[display] }}
      </button>
      <recursive-list
        v-if="isObject(item)"
        :getter-list="getterList"
        :display="display"
        :valid-property="validProperty"
        @selected="$emit('selected', $event)"
        :modal-mutation-name="modalMutationName"
        :action-mutation-name="actionMutationName"
        :object-list="item"/>
    </li>
  </ul>
</template>

<script>
import RecursiveList from './recursiveList.vue'
import { MutationNames } from '../store/mutations/mutations'
import { GetterNames } from '../store/getters/getters'

export default {
  name: 'RecursiveList',

  components: { RecursiveList },

  props: ['objectList', 'modalMutationName', 'actionMutationName', 'display', 'getterList', 'validProperty'],

  emits: ['selected'],

  computed: {
    savedList () {
      return this.getterList
        ? this.$store.getters[GetterNames[this.getterList]]
        : []
    },

    orderList() {
      let sortable = []
      let sortableObject = {}

      for (var key in this.objectList) {
        sortable.push([key, this.objectList[key]]);
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
    },

    taxon() {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },

  methods: {
    selectItem (optionSelected) {
      this.$emit('selected', optionSelected)
      this.$store.commit(MutationNames[this.modalMutationName], false)
    },
    findExist (status) {
      return this.savedList.find(element => element.type == status.type)
    },
    isForThisRank (item) {
      return (item.hasOwnProperty(this.validProperty) ? !(item[this.validProperty].includes(this.taxon.rank_string)) : false)
    },
    isObject (item) {
      return typeof item === 'object'
    }
  }
}

</script>
