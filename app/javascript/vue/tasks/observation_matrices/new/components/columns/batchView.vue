<template>
  <div>
    <template
      v-for="(object, key) in list.totals"
      :key="key"
    >
      <div
        class="tag_list"
        v-if="object"
      >
        <div class="capitalize tag_label">{{ key }}</div>
        <div class="tag_total">{{ object }}</div>
        <button
          class="button normal-input button-submit"
          type="button"
          @click="batchLoad(key, matrixId)"
        >
          Create
        </button>
      </div>
    </template>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { CreateColumnBatchLoad } from '../../request/resources'
import { GetterNames } from '../../store/getters/getters'
import ActionNames from '../../store/actions/actionNames'

const props = defineProps({
  list: {
    type: Object,
    required: true
  },

  batchType: {
    type: String,
    required: true
  }
})

const store = useStore()

const matrixId = computed(() => store.getters[GetterNames.GetMatrix].id)

function batchLoad(classType, matrixId) {
  let object = {
    observation_matrix_id: matrixId,
    batch_type: props.batchType,
    klass: classType
  }

  CreateColumnBatchLoad(object).then(() => {
    store.dispatch(ActionNames.GetMatrixObservationColumns, matrixId.value)
  })
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
