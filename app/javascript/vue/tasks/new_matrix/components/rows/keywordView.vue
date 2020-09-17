<template>
  <div>
    <div v-for="object in list">
      <hr>
      <b><p v-html="object.object.object_tag"/></b>
      <div
        class="tag_list"
        v-for="(keywordCount, key) in object.totals">
        <div class="capitalize tag_label">{{ key }}</div>
        <div class="tag_total">{{ keywordCount }}</div>
        <template v-if="keywordCount > 0">
          <button
            class="button normal-input button-submit"
            type="button"
            @click="batchLoad(key, matrixId, key, object.object.id)">Create
          </button>
          <button
            v-if="key != 'total'"
            class="separate-left button normal-input button-delete"
            type="button"
            @click="removeKeyword(matrixId, key)">Remove
          </button>
        </template>
      </div>
    </div>
  </div>
</template>
<script>

  import { CreateRowBatchLoad, BatchRemoveKeyword } from '../../request/resources'
  import { GetterNames } from '../../store/getters/getters'
  import { ActionNames } from '../../store/actions/actions'

  export default {
    props: {
      list: {
        type: Object,
        required: true
      },
      batchType: {
        type: String,
        required: true
      },
    },
    computed: {
      matrixId() {
        return this.$store.getters[GetterNames.GetMatrix].id
      }
    },
    methods: {
      batchLoad(classType, matrixId, type, keywordId) {
        let object = {
          observation_matrix_id: matrixId,
          keyword_id: keywordId,
          batch_type: 'tags',
          klass: (type == 'total' ? undefined : type)
        }
        CreateRowBatchLoad(object).then((response) => {
          this.$store.dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
        })
      },
      removeKeyword(id, type) {
        BatchRemoveKeyword(id, type).then(response => {
          this.$store.dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
        })
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