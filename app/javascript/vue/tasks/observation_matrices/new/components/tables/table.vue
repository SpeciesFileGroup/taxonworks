<template>
  <table class="vue-table table-striped">
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
      <template #item="{ element }">
        <tr class="list-complete-item">
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
            <div class="horizontal-left-content gap-small">
              <a
                v-if="code"
                type="button"
                target="_blank"
                class="circle-button btn-row-coder"
                :title="row ? 'Matrix row coder' : 'Matrix column coder'"
                :href="
                  row
                    ? `/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${element.id}`
                    : `/tasks/observation_matrices/matrix_column_coder/index?observation_matrix_column_id=${element.id}`
                "
              />
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
  <div
    v-if="!list.length"
    class="padding-medium"
  >
    None
  </div>
</template>

<script>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import Draggable from 'vuedraggable'
import ObjectValidation from '@/components/soft_validations/objectValidation.vue'
import { GetterNames } from '../../store/getters/getters'
import { OTU, EXTRACT, DESCRIPTOR, SPECIMEN } from '@/constants/index.js'

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

  emits: ['order', 'delete'],

  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    },

    sortable() {
      return this.$store.getters[GetterNames.GetSettings].sortable
    },

    enableSoftValidation() {
      return this.$store.getters[GetterNames.GetSettings].softValidations
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
    deleteItem(item) {
      if (
        window.confirm(
          this.warningMessage
            ? this.warningMessage
            : "You're trying to delete this record. Are you sure want to proceed?"
        )
      ) {
        this.$emit('delete', item)
      }
    },

    onSortable() {
      const ids = this.newList.map((object) => object.id)
      this.$emit('order', ids)
    },

    getValue(object, attributes) {
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
    }
  }
}
</script>
