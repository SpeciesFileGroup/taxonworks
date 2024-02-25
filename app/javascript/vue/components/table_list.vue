<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th
            v-for="item in header"
            v-html="item"
          />
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <tr
          v-for="(item, index) in list"
          :key="rowKey ? item[rowKey] : item.id"
          class="list-complete-item contextMenuCells"
          :class="{ even: index % 2 }"
        >
          <td
            v-for="attr in attributes"
            v-html="getValue(item, attr)"
          />
          <td>
            <div class="horizontal-right-content gap-small">
              <slot
                :item="item"
                name="options"
              />
              <PdfComponent
                v-if="pdf"
                :pdf="item.document"
              />
              <RadialAnnotator
                v-if="annotator"
                :global-id="item.global_id"
              />
              <RadialObject
                v-if="quickForms"
                :global-id="item.global_id"
              />
              <RadialNavigator
                v-if="navigator"
                :global-id="item.global_id"
              />
              <span
                v-if="edit"
                class="circle-button btn-edit"
                @click="emit('edit', Object.assign({}, item))"
              />
              <span
                v-if="destroy"
                class="circle-button btn-delete"
                @click="deleteItem(item)"
                >Remove
              </span>
            </div>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script setup>
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import PdfComponent from '@/components/ui/Button/ButtonPdf'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },
  attributes: {
    type: Array,
    required: true
  },
  header: {
    type: Array,
    default: () => []
  },
  rowKey: {
    type: String,
    default: undefined
  },
  destroy: {
    type: Boolean,
    default: true
  },
  deleteWarning: {
    type: Boolean,
    default: true
  },
  navigator: {
    type: Boolean,
    default: false
  },
  quickForms: {
    type: Boolean,
    default: false
  },
  annotator: {
    type: Boolean,
    default: true
  },
  edit: {
    type: Boolean,
    default: false
  },
  pdf: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['delete', 'edit'])

function getValue(object, attributes) {
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
  } else {
    if (attributes.substr(0, 1) === '@') {
      return attributes.substr(1, attributes.length)
    }
  }
  return object[attributes]
}

function deleteItem(item) {
  if (props.deleteWarning) {
    if (
      window.confirm(
        `You're trying to delete this record. Are you sure want to proceed?`
      )
    ) {
      emit('delete', item)
    }
  } else {
    emit('delete', item)
  }
}
</script>
<style lang="scss">
.vue-table-container {
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

.list-complete-enter-active,
.list-complete-leave-active {
  opacity: 0;
  font-size: 0px;
  border: none;
}
</style>
