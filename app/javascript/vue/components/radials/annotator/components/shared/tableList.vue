<template>
  <div class="vue-table-container-shared">
    <table class="vue-table">
      <thead>
        <tr>
          <th
            v-for="item in header"
            :key="item.id"
            v-html="item"
          />
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item"
        >
          <td
            v-for="attr in attributes"
            v-html="getValue(item, attr)"
            :key="attr"
          />
          <td>
            <div class="horizontal-right-content gap-small">
              <citations-count
                :target="targetCitations"
                :object="item"
              />
              <RadialAnnotator :global-id="item.global_id" />

              <VBtn
                v-if="edit"
                circle
                color="update"
                @click="$emit('edit', Object.assign({}, item))"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>

              <VBtn
                v-if="destroy"
                circle
                color="destroy"
                @click="deleteItem(item)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import CitationsCount from './citationsCount.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineProps({
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
  destroy: {
    type: Boolean,
    default: true
  },
  annotator: {
    type: Boolean,
    default: false
  },
  edit: {
    type: Boolean,
    default: false
  },
  targetCitations: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['delete'])

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
  if (
    window.confirm(
      `You're trying to delete this record. Are you sure want to proceed?`
    )
  ) {
    emit('delete', item)
  }
}
</script>
