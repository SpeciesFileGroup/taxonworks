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
    </li>
  </transition-group>
</template>
<script>
import RadialAnnotator from '../../annotator'
import CitationsCount from './citationsCount'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

export default {
  components: {
    RadialAnnotator,
    CitationsCount,
    VIcon,
    VBtn
  },
  props: {
    list: {
      type: Array,
      default: () => []
    },
    annotator: {
      type: Boolean,
      default: true
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
  },
  mounted() {
    this.$options.components['RadialAnnotator'] = RadialAnnotator
  },
  methods: {
    displayName(item) {
      if (typeof this.label === 'string') {
        return item[this.label]
      } else {
        let tmp = item
        this.label.forEach(function (label) {
          tmp = tmp[label]
        })
        return tmp
      }
    },
    checkHighlight(item) {
      if (this.highlight) {
        if (this.highlight.key) {
          return item[this.highlight.key] == this.highlight.value
        } else {
          return item == this.highlight.value
        }
      }
      return false
    },
    deleteItem(item) {
      if (
        window.confirm(
          `You're trying to delete this record. Are you sure want to proceed?`
        )
      ) {
        this.$emit('delete', item)
      }
    }
  }
}
</script>
