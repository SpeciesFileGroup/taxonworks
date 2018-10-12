<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Geographic area</th>
          <th>Absent</th>
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
              :class="{ absent: item.is_absent }"
              v-html="item.geographic_area.name"/>
          </td>
          <td v-html="item.is_absent"/>
          <td class="vue-table-options">
            <citation-count
              :object="item"
              target="asserted_distributions"/>
            <radial-annotator :global-id="item.global_id"/>
            <span
              v-if="edit"
              class="circle-button btn-edit"
              @click="$emit('edit', Object.assign({}, item))"/>
            <span
              v-if="destroy"
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

  import RadialAnnotator from 'components/annotator/annotator.vue'
  import CitationCount from '../shared/citationsCount.vue'

  export default {
    components: {
      RadialAnnotator,
      CitationCount
    },
    props: {
      list: {
        type: Array,
        default: () => {
          return []
        }
      },
      attributes: {
        type: Array,
        required: true
      },
      header: {
        type: Array,
        default: () => {
          return []
        }
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
      }
    },
    mounted() {
      this.$options.components['RadialAnnotator'] = RadialAnnotator
    },
    methods: {
      getValue(object, attributes) {
        if (Array.isArray(attributes)) {
          let obj = object

          for (var i = 0; i < attributes.length; i++) {
            if(obj.hasOwnProperty(attributes[i])) {
              obj = obj[attributes[i]]
            }
            else {
              return null
            }
          }
          return obj
        }
        else {
          if(attributes.substr(0,1) === "@") {
            return attributes.substr(1, attributes.length)
          }
        }
        return object[attributes]
      },
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
  .absent {
    background-color: #000;
    color: #FFF;
  }
</style>
