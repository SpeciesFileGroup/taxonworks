<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th
            v-for="(label, index) in header"
            :key="index"
          >
            {{ label }}
          </th>
        </tr>
      </thead>
      <draggable
        element="tbody"
        v-model="newList"
        :disabled="!sortable"
        tag="tbody"
        item-key="id"
        @end="onSortable"
      >
        <template #item="{ element, index }">
          <tr
            :class="{ even: index % 2 }"
            class="list-complete-item contextMenuCells"
          >
            <td
              class="full_width"
              v-for="(label, key) in attributes"
              :key="key"
            >
              <div class="middle">
                <div class="margin-small-right">
                  <object-validation
                    v-if="code && enableSoftValidation"
                    :global-id="element.global_id"
                  />
                </div>
                <span v-html="getValue(element, label)" />
              </div>
            </td>
            <td>
              <div class="horizontal-left-content">
                <a
                  v-if="edit && !element.is_dynamic"
                  type="button"
                  class="circle-button btn-edit"
                  :href="getUrlLink(element)"
                />

                <a
                  v-if="code"
                  type="button"
                  target="_blank"
                  class="circle-button btn-row-coder"
                  title="Matrix row coder"
                  :href="`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${element.id}`"
                />
                <radial-annotator :global-id="getValue(element, globalIdPath)" />
                <radial-object :global-id="getValue(element, globalIdPath)" />
                <span
                  v-if="filterRemove(element)"
                  class="circle-button btn-delete"
                  @click="deleteItem(element)"
                >Remove
                </span>
                <span
                  v-else
                  class="empty-option"
                />
              </div>
            </td>
          </tr>
        </template>
      </draggable>
    </table>
  </div>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial.vue'
import Draggable from 'vuedraggable'
import ObjectValidation from 'components/soft_validations/objectValidation.vue'
import { GetterNames } from '../../store/getters/getters'
import {
  OTU,
  EXTRACT,
  DESCRIPTOR,
  SPECIMEN
} from 'constants/index.js'

export default {
  components: {
    RadialAnnotator,
    Draggable,
    RadialObject,
    ObjectValidation
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
      default: () => true
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

  emits: [
    'order',
    'delete'
  ],

  computed: {
    matrix () {
      return this.$store.getters[GetterNames.GetMatrix]
    },

    sortable () {
      return this.$store.getters[GetterNames.GetSettings].sortable
    },

    enableSoftValidation () {
      return this.$store.getters[GetterNames.GetSettings].softValidations
    }
  },

  data () {
    return {
      newList: [],
      urlTypes: {
        [OTU]: '/otus/',
        [SPECIMEN]: '/collection_objects/',
        [DESCRIPTOR]: '/tasks/descriptors/new_descriptor/',
        [EXTRACT]: '/tasks/extracts/new_extract?extract_id='
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

    onSortable () {
      const ids = this.newList.map(object => object.id)
      this.$emit('order', ids)
    },

    getValue (object, attributes) {
      if (Array.isArray(attributes)) {
        let obj = object

        for (let i = 0; i < attributes.length; i++) {
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

    getUrlLink (item) {
      return this.row
        ? `${this.urlTypes[item.observation_object.base_class]}${item.observation_object.id}`
        : `/tasks/descriptors/new_descriptor?descriptor_id=${item.descriptor_id}&observation_matrix_id=${this.matrix.id}`
    }
  }
}
</script>
