<template>
  <ul class="tree-status">
    <li
      v-for="(item, key) in orderList"
      v-if="item.hasOwnProperty(display)"
      :key="key">
      <button
        type="button"
        :value="item.type"
        @click="addStatus(item)"
        :disabled="(item.disabled || (findExist(item) != undefined))"
        class="button button-default normal-input">
        {{ item[display] }}
      </button>
      <recursive-list
        :getter-list="getterList"
        :display="display"
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
import { ActionNames } from '../store/actions/actions'

export default {
  components: {
    RecursiveList
  },
  name: 'RecursiveList',
  props: ['objectList', 'modalMutationName', 'actionMutationName', 'display', 'getterList'],
  computed: {
    savedList () {
      if (this.getterList != undefined) {
        return this.$store.getters[GetterNames[this.getterList]]
      } else {
        return []
      }
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
    }
  },
  methods: {
    addStatus: function (status) {
      this.$store.commit(MutationNames[this.modalMutationName], false)
      this.$store.dispatch(ActionNames[this.actionMutationName], status)
    },
    findExist: function (status) {
      return this.savedList.find(function (element) {
        return (element.type == status.type)
      })
    }
  }
}

</script>
