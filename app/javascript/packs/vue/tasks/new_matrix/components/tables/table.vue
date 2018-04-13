<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Name</th>
          <th>Options</th>
        </tr>
      </thead>
      <draggable
        element="tbody"
        v-model="newList"
        @end="onSortable">
        <tr
          v-for="(item, index) in newList"
          class="list-complete-item">
          <td
            v-for="label in attributes"
            v-html="getValue(item, label)"/>
          <td class="vue-table-options">
            <radial-annotator
              :global-id="getValue(item, globalIdPath)"/>
            <span
              class="circle-button btn-delete"
              @click="$emit('delete', item)">Remove
            </span>
          </td>
        </tr>
      </draggable>
    </table>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import Draggable from 'vuedraggable'

  export default {
    components: {
      Autocomplete,
      RadialAnnotator,
      Draggable
    },
    props: {
      list: {
        type: Array,
        required: true
      },
      matrixId: {
        type: Number,
        required: true
      },
      attributes: {
        type: Array,
        required: true
      },
      globalIdPath: {
        type: Array,
        required: true
      }
    },
    data() {
      return {
        newList: []
      }
    },
    watch: {
      list: {
        handler(newVal) {
          this.newList = newVal
        },
        immediate: true
      }
    },
    methods: {
      onSortable: function () {
        let ids = this.newList.map(object => object.id)
        this.$emit('order', ids)
      },
      getValue(object, attributes) {
        if (Array.isArray(attributes)) {
          let obj = object

          for (var i = 0; i < attributes.length; i++) {
            if(obj.hasOwnProperty(attributes[i])) {
              obj = obj[attributes[i]]
            }
            else {
              return null
            }
          }
          return obj
        }
        return object[attributes]
      }
    }
  }
</script>
<style lang="scss" scoped>
  .vue-table-container {
    overflow-y: scroll;
    padding: 0px;
    position: relative;
  }

  .vue-table {
    width: 100%;
    .vue-table-options {
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
    }
    tr {
      cursor: default;
    }
  }

  .list-complete-item {
    justify-content: space-between;
    transition: all 0.5s, opacity 0.2s;
  }

  .list-complete-enter-active, .list-complete-leave-active {
    opacity: 0;
    font-size: 0px;
    border: none;
  }
</style>