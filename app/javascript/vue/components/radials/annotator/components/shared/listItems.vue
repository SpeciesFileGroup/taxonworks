<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul"
  >
    <li
      v-for="item in list"
      :key="item.id"
      class="list-complete-item flex-separate middle"
      :class="{ highlight: checkHighlight(item) }"
    >
      <span
        class="list-item"
        v-html="displayName(item)"
      />
      <div class="horizontal-right-content">
        <CitationsCount
          :target="targetCitations"
          :object="item"
        />
        <RadialAnnotator
          v-if="annotator"
          :global-id="item.global_id"
        />
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
          v-if="remove"
          icon
          variant="tonal"
          color="destroy"
          @click="deleteItem(item)"
        >
          <IconTrash class="w-4 h-4" />
        </VBtn>
      </div>
    </li>
  </transition-group>
</template>
<script setup>
import RadialAnnotator from '../../annotator'
import CitationsCount from './citationsCount'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  targetCitations: {
    type: String,
    required: true
  },

  label: {
    type: [String, Array],
    required: true
  },

  edit: {
    type: Boolean,
    default: false
  },

  remove: {
    type: Boolean,
    default: true
  },

  annotator: {
    type: Boolean,
    default: false
  },

  highlight: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['delete', 'edit'])

function displayName(item) {
  if (typeof props.label === 'string') {
    return item[props.label]
  } else {
    let tmp = item

    props.label.forEach((label) => {
      tmp = tmp[label]
    })

    return tmp
  }
}

function checkHighlight(item) {
  if (props.highlight) {
    if (props.highlight.key) {
      return item[props.highlight.key] == props.highlight.value
    } else {
      return item == props.highlight.value
    }
  }
  return false
}

function deleteItem(item) {
  if (
    window.confirm(
      `You're trying to delete this record. Are you sure you want to proceed?`
    )
  ) {
    emit('delete', item)
  }
}
</script>
