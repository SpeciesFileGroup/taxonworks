<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th
            v-for="item in header"
            v-html="item"/>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item">
          <td
            v-for="attr in types[item.base_class].attributes"
            v-html="getValue(item, attr)"/>
          <td class="vue-table-options">
            <radial-annotator :global-id="item.annotated_object.global_id"/>
            <radial-object :global-id="item.annotated_object.global_id"/>
            <span
              class="circle-button btn-delete"
              @click="deleteObject(item)">Remove
            </span>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial'

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },

  props: {
    list: {
      type: Array,
      default: () => []
    },
    header: {
      type: Array,
      default: () => []
    },
    types: {
      type: Object,
      required: true
    }
  },

  emits: ['edit', 'delete'],

  mounted () {
    this.$options.components['RadialAnnotator'] = RadialAnnotator
  },

  methods: {
    getValue(object, attributes) {
      if (Array.isArray(attributes)) {
        let obj = object

        for (var i = 0; i < attributes.length; i++) {
          if (obj.hasOwnProperty(attributes[i])) {
            obj = obj[attributes[i]]
          }
          else {
            return null
          }
        }
        return obj
      }
      else {
        if (attributes.substr(0,1) === "@") {
          return attributes.substr(1, attributes.length)
        }
      }
      return object[attributes]
    },

    editObject (item) {
      this.$emit('edit', item)
    },

    deleteObject (item) {
      if (window.confirm(`You're trying to delete a record. Are you sure want to proceed?`)) {
        this.$emit('delete', item)
      }
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
</style>