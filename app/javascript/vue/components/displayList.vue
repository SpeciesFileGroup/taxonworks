<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul"
  >
    <li
      v-for="(item, index) in list"
      :key="setKey ? item[setKey] : item.id || JSON.stringify(item)"
      class="list-complete-item flex-separate middle"
      :class="{ highlight: checkHighlight(item) }"
    >
      <span>
        <soft-validation
          v-if="validations"
          :global-id="item.global_id"
        />
        <span
          class="list-item"
          v-html="displayName(item)"
        />
      </span>
      <div class="horizontal-right-content gap-small">
        <slot
          name="options"
          :item="item"
        />
        <a
          v-if="download"
          class="btn-download circle-button"
          :href="getPropertyValue(item, download)"
          download
        />
        <PdfButton
          v-if="pdf && pdfExist(item)"
          :pdf="pdfExist(item)"
        />
        <RadialAnnotator
          v-if="annotator"
          :global-id="item.global_id"
        />
        <RadialObject
          v-if="radialObject && item.hasOwnProperty('global_id')"
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
          :color="softDelete ? 'primary' : 'destroy'"
          @click="deleteItem(item, index)"
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
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import SoftValidation from '@/components/soft_validations/objectValidation.vue'
import PdfButton from '@/components/ui/Button/ButtonPdf.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

export default {
  components: {
    RadialAnnotator,
    SoftValidation,
    PdfButton,
    VBtn,
    VIcon
  },

  props: {
    list: {
      type: Array,
      default: () => []
    },
    download: {
      type: String,
      default: undefined
    },
    label: {
      type: [String, Array],
      default: undefined
    },
    setKey: {
      type: String,
      default: undefined
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
    radialObject: {
      type: Boolean,
      default: false
    },
    highlight: {
      type: Object,
      default: undefined
    },
    deleteWarning: {
      type: Boolean,
      default: true
    },
    warning: {
      type: Boolean,
      default: true
    },
    validations: {
      type: Boolean,
      default: false
    },
    softDelete: {
      type: Boolean,
      default: false
    },
    pdf: {
      type: Boolean,
      default: false
    }
  },

  emits: ['delete', 'edit', 'deleteIndex'],

  beforeCreate() {
    this.$options.components['RadialAnnotator'] = RadialAnnotator
    this.$options.components['RadialObject'] = RadialObject
  },

  methods: {
    displayName(item) {
      if (!this.label) return item
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

    deleteItem(item, index) {
      if (this.deleteWarning && this.warning) {
        if (
          window.confirm(
            `You're trying to delete this record. Are you sure want to proceed?`
          )
        ) {
          this.$emit('delete', item)
          this.$emit('deleteIndex', index)
        }
      } else {
        this.$emit('delete', item)
        this.$emit('deleteIndex', index)
      }
    },

    getPropertyValue(item, stringPath) {
      let keys = stringPath.split('.')
      if (keys.length === 1) {
        return item[stringPath]
      } else {
        let value = item
        keys.forEach((key) => {
          value = value[key]
        })
        return value
      }
    },

    pdfExist(item) {
      if (item.hasOwnProperty('target_document')) {
        return item.target_document
      }
      if (item.hasOwnProperty('document')) {
        return item.document
      }

      return
    }
  }
}
</script>
<style lang="scss">
.table-entrys-list {
  padding: 0px;
  position: relative;

  .list-controls {
    display: flex;
    align-items: center;
    flex-direction: row;
    justify-content: flex-end;
    .circle-button {
      margin-left: 4px !important;
    }
  }

  .highlight {
    background-color: #e3e8e3;
  }

  .list-item {
    white-space: normal;
    a {
      padding-left: 4px;
      padding-right: 4px;
    }
  }

  .list-complete-item {
    justify-content: space-between;
    transition: all 0.5s, opacity 0.2s;
    margin: 0px;
    padding: 1em 0;
    border: 0px;
    border-bottom: 1px solid #f5f5f5;
  }

  .list-complete-enter,
  .list-complete-leave-to {
    opacity: 0;
    font-size: 0px;
    border: none;
    transform: scale(0);
  }

  .list-complete-leave-active {
    width: 100%;
    position: absolute;
  }
}
</style>
