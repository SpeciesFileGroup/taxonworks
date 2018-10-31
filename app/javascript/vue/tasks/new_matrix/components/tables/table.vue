<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th v-for="label in header"> {{ label }} </th>
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
            <template v-if="!item.is_dynamic">
              <template v-if="edit">
                <a
                  v-if="row"
                  type="button"
                  target="_blank"
                  class="circle-button btn-edit"
                  :href="getUrlType(item.row_object.base_class, item.row_object.id)"/>
                <a
                  v-else
                  type="button"
                  target="_blank"
                  class="circle-button btn-edit"
                  :href="`/tasks/descriptors/new_descriptor/${item.descriptor_id}`"/>
              </template>               
              <a
                v-if="code"
                type="button"
                target="_blank"
                class="circle-button btn-row-coder"
                :href="`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${item.id}`"/>
              <radial-annotator
              :global-id="getValue(item, globalIdPath)"/>
            </template>
            <template>
              <span
                v-if="filterRemove(item)"
                class="circle-button btn-delete"
                @click="deleteItem(item)">Remove
              </span>
              <span
                v-else
                class="empty-option"/>
            </template>
          </td>
        </tr>
      </draggable>
    </table>
  </div>
</template>

<script>

  import Autocomplete from 'components/autocomplete.vue'
  import RadialAnnotator from 'components/annotator/annotator.vue'
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
      row: {
        type: Boolean,
        default: true
      },
      matrixId: {
        type: Number,
        required: true
      },
      code: {
        type: Boolean,
        default: false
      },
      attributes: {
        type: Array,
        required: true
      },
      header: {
        type: Array,
        required: true
      },
      filterRemove: {
        type: Function,
        default: (item) => { return true }
      },
      edit: {
        type: Boolean,
        default: false
      },
      globalIdPath: {
        type: Array,
        required: true
      }
    },
    data() {
      return {
        newList: [],
        urlTypes: {
          'Otu': '/otus/',
          'Specimen': '/collection_objects/',
          'Descriptor': '/tasks/descriptors/new_descriptor/'
        }
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
      deleteItem(item) {
        if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
          this.$emit('delete', item)
        }
      },
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
      },
      getUrlType(type, id) {
        return `${this.urlTypes[type]}${id}`
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
    margin-top: 0px;
    .vue-table-options {
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
      .empty-option {
        width: 24px;
        margin: 5px;
      }
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