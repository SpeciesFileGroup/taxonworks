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
              <RadialNavigator :global-id="getValue(element, globalIdPath)" />
              <VBtn
                v-if="code"
                icon
                color="primary"
                variant="tonal"
                target="_blank"
                :title="row ? 'Matrix row coder' : 'Matrix column coder'"
                :href="
                  row
                    ? `/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${element.id}`
                    : `/tasks/observation_matrices/matrix_column_coder/index?observation_matrix_column_id=${element.id}`
                "
              >
                <IconRowMatrix class="w-4 h-4" />
              </VBtn>
              <VBtn
                v-if="filterRemove(element)"
                icon
                color="destroy"
                variant="tonal"
                @click="deleteItem(element)"
              >
                <IconTrash class="w-4 h-4" />
              </VBtn>
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

<script setup>
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import Draggable from 'vuedraggable'
import ObjectValidation from '@/components/soft_validations/objectValidation.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconRowMatrix from '@/components/Icon/IconRowMatrix.vue'
import { GetterNames } from '../../store/getters/getters'
import { useStore } from 'vuex'
import { computed, ref, watch } from 'vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

const props = defineProps({
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
})

const emit = defineEmits(['order', 'delete'])

const store = useStore()

const matrix = computed(() => store.getters[GetterNames.GetMatrix])

const sortable = computed(() => store.getters[GetterNames.GetSettings].sortable)

const enableSoftValidation = computed(
  () => store.getters[GetterNames.GetSettings].softValidations
)

const newList = ref([])

watch(
  () => props.list,
  (newVal) => {
    newList.value = newVal
  },
  { immediate: true }
)

function deleteItem(item) {
  if (
    window.confirm(
      props.warningMessage ||
        "You're trying to delete this record. Are you sure you want to proceed?"
    )
  ) {
    emit('delete', item)
  }
}

function onSortable() {
  const ids = newList.value.map((object) => object.id)
  emit('order', ids)
}

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
  }
  return object[attributes]
}
</script>
