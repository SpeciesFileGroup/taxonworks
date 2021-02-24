<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th v-for="label in header">
            {{ label }}
          </th>
        </tr>
      </thead>
      <draggable
        element="tbody"
        v-model="newList"
        :disabled="!sortable"
        @end="onSortable"
      >
        <tr
          v-for="(item, index) in newList"
          :class="{ even: index % 2 }"
          class="list-complete-item contextMenuCells"
        >
          <td
            class="full_width"
            v-for="label in attributes"
            v-html="getValue(item, label)"
          />
          <td>
            <div class="horizontal-left-content">
              <template v-if="!item.is_dynamic">
                <template v-if="edit">
                  <a
                    v-if="row"
                    type="button"
                    class="circle-button btn-edit"
                    :href="getUrlType(item.row_object.base_class, item.row_object.id)"
                  />
                  <a
                    v-else
                    type="button"
                    class="circle-button btn-edit"
                    :href="`/tasks/descriptors/new_descriptor?descriptor_id=${item.descriptor_id}&observation_matrix_id=${matrix.id}`"
                  />
                </template>
                <a
                  v-if="code"
                  type="button"
                  target="_blank"
                  class="circle-button btn-row-coder"
                  title="Matrix row coder"
                  :href="`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${item.id}`"
                />
                <radial-annotator :global-id="getValue(item, globalIdPath)" />
                <radial-object :global-id="getValue(item, globalIdPath)" />
              </template>
              <template>
                <span
                  v-if="filterRemove(item)"
                  class="circle-button btn-delete"
                  @click="deleteItem(item)"
                >Remove
                </span>
                <span
                  v-else
                  class="empty-option"
                />
              </template>
            </div>
          </td>
        </tr>
      </draggable>
    </table>
  </div>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial.vue'
import Draggable from 'vuedraggable'
import { GetterNames } from '../../store/getters/getters'

export default {
  components: {
    RadialAnnotator,
    Draggable,
    RadialObject
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
    },
    warningMessage: {
      type: String,
      default: undefined
    }
  },
  computed: {
    matrix () {
      return this.$store.getters[GetterNames.GetMatrix]
    },
    sortable () {
      return this.$store.getters[GetterNames.GetSettings].sortable
    }
  },
  data () {
    return {
      newList: [],
      urlTypes: {
        Otu: '/otus/',
        Specimen: '/collection_objects/',
        Descriptor: '/tasks/descriptors/new_descriptor/'
      }
    }
  },
  watch: {
    list: {
      handler (newVal) {
        this.newList = newVal
      },
      immediate: true
    }
  },
  methods: {
    deleteItem (item) {
      if (window.confirm(this.warningMessage ? this.warningMessage : "You're trying to delete this record. Are you sure want to proceed?")) {
        this.$emit('delete', item)
      }
    },
    onSortable: function () {
      const ids = this.newList.map(object => object.id)
      this.$emit('order', ids)
    },
    getValue (object, attributes) {
      if (Array.isArray(attributes)) {
        let obj = object

        for (var i = 0; i < attributes.length; i++) {
          if (obj.hasOwnProperty(attributes[i])) {
            obj = obj[attributes[i]]
          } else {
            return null
          }
        }
        return obj
      }
      return object[attributes]
    },
    getUrlType (type, id) {
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
</style>
