<template>
  <div>
    <div
      class="tag_list"
      v-for="(object, key) in list.totals"
      v-if="object">
      <div class="capitalize tag_label">{{ key }}</div>
      <div class="tag_total">{{ object }}</div>
      <button
        class="button normal-input button-submit"
        type="button"
        @click="batchLoad(key, matrixId)">Create
      </button>
      <button
        v-if="key != 'total'"
        class="separate-left button normal-input button-delete"
        type="button"
        @click="removeKeyword(item.object.id, key)">Remove
      </button>
    </div>
  </div>
</template>

<script>

  import { CreateRowBatchLoad } from '../../request/resources'
  import { GetterNames } from '../../store/getters/getters'

  export default {
    props: {
      list: {
        type: Object,
        required: true
      }
    },
    computed: {
      matrixId() {
        return this.$store.getters[GetterNames.GetMatrix].id
      }
    },
    methods: {
      batchLoad(classType, matrixId) {
        let object = {
          observation_matrix_id: matrixId,
          batch_type: this.batchType,
          klass: classType
        }
        CreateRowBatchLoad(object)
      }
    }
  }
</script>

<style lang="scss" scoped>
  .tag_list {
    margin-top: 0.5em;
    align-items: center;
    text-align: right;
    display: flex;
    .tag_label {
      width: 130px;
      min-width: 130px;
    }
    .tag_total {
      margin-left: 1em;
      margin-right: 1em;
      text-align: left;
      min-width: 50px;
    }
  }
</style>