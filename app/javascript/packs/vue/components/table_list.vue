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
            v-for="attr in attributes"
            v-html="getValue(item, attr)"/>
          <td class="vue-table-options">
            <span
              v-if="edit"
              class="circle-button btn-edit"
              @click="$emit('edit', Object.assign({}, item))"/>
            <span
              v-if="destroy"
              class="circle-button btn-delete"
              @click="$emit('delete', item)">Remove
            </span>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script>
  export default {
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
      edit: {
        type: Boolean,
        default: false
      }
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
        return object[attributes]
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
