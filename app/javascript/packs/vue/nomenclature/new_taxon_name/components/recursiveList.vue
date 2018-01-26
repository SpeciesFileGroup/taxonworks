<template>
  <ul class="tree-status">
    <li v-for="item, key in objectList" v-if="item.hasOwnProperty(display)">
      <button type="button" :value="item.type" @click="addStatus(item)" :disabled="(item.disabled || (findExist(item) != undefined))" class="button button-default normal-input">
        {{ item[display] }}
      </button>
      <recursive-list :getter-list="getterList" :display="display" :modal-mutation-name="modalMutationName" :action-mutation-name="actionMutationName" :object-list="item"/>
    </li>
  </ul>
</template>

<script>
var recursiveList = require('./recursiveList.vue').default
const MutationNames = require('../store/mutations/mutations').MutationNames
const GetterNames = require('../store/getters/getters').GetterNames
const ActionNames = require('../store/actions/actions').ActionNames

export default {
  components: {
    recursiveList
  },
  computed: {
    savedList () {
      if (this.getterList != undefined) {
        return this.$store.getters[GetterNames[this.getterList]]
      } else {
        return []
      }
    }
  },
  name: 'RecursiveList',
  props: ['objectList', 'modalMutationName', 'actionMutationName', 'display', 'getterList'],
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
