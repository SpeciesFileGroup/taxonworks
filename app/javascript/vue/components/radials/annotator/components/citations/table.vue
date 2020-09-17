<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Citation</th>
          <th></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item">
          <td>
            <span
              :class="{ originalCitation: item.is_original }"
              v-html="item.object_tag"/>
            <soft-validation
              class="margin-small-left"
              :global-id="item.global_id"/>
          </td>
          <td class="vue-table-options">
            <a
              class="button-default circle-button btn-citation"
              :href="`/tasks/nomenclature/by_source?source_id=${item.source_id}`"
              target="blank"/>
            <pdf-button
              v-if="item.hasOwnProperty('target_document')"
              :pdf="item.target_document"/>
            <radial-annotator :global-id="item.global_id"/>
            <span
              class="circle-button btn-edit"
              @click="$emit('edit', Object.assign({}, item))"/>
            <span
              class="circle-button btn-delete"
              @click="deleteItem(item)">Remove
            </span>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import PdfButton from 'components/pdfButton.vue'
import SoftValidation from 'components/soft_validations/objectValidation'

export default {
  components: {
    RadialAnnotator,
    SoftValidation,
    PdfButton
  },
  props: {
    list: {
      type: Array,
      default: () => {
        return []
      }
    },
  },
  mounted() {
    this.$options.components['RadialAnnotator'] = RadialAnnotator
  },
  methods: {
    deleteItem(item) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('delete', item)
      }
    }
  }
}
</script>
<style lang="scss" scoped>
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

  .list-complete-enter-active, .list-complete-leave-active {
    opacity: 0;
    font-size: 0px;
    border: none;
  }
  .originalCitation {
    padding: 5px;
    border-radius: 3px;
    background-color: #006ebf;
    color: #FFF;
  }
</style>
