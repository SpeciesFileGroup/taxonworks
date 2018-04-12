<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Name</th>
          <th>Options</th>
        </tr>
      </thead>
      <tbody>
        <draggable
          v-model="newList"
          @end="onSortable">
          <tr
            v-for="(item, index) in newList"
            class="list-complete-item">
            <td>{{ item.descriptor.name }} </td>
          </tr>
        </draggable>
      </tbody>
    </table>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import Draggable from 'vuedraggable'
  import ActionNames from '../../store/actions/actionNames'
  import { SortColumns } from '../../request/resources'

  export default {
    components: {
      Autocomplete,
      Draggable
    },
    props: {
      list: {
        type: Array,
        required: true
      },
      matrixId: {
        type: Number,
        required: true
      }
    },
    data() {
      return {
        newList: []
      }
    },
    watch: {
      list: {
        handler(newVal) {
          this.newList = newVal
        },
        immediate: true
      }
    },
    methods: {
      onSortable: function () {
        let ids = this.newList.map(object => object.id)
        SortColumns(ids).then(() => {
          this.$store.dispatch(ActionNames.GetMatrixObservationColumns, this.matrixId)
        })
        this.$emit('order', ids)
      },
    }
  }
</script>
