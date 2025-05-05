<template>
  <div class="panel basic-information">
    <div class="header flex-separate">
      <h3>Matrix</h3>
    </div>
    <div class="body">
      <div class="field label-above">
        <label>Name</label>
        <div class="horizontal-left-content full_width">
          <input
            v-model="matrixName"
            autofocus
            class="full_width margin-small-right"
            type="text"
          />
          <VBtn
            medium
            color="create"
            @click="() => store.dispatch(ActionNames.SaveMatrix)"
          >
            {{ matrix.id ? 'Update' : 'Create' }}
          </VBtn>
        </div>
      </div>
      <MatrixParent class="field" />
      <div class="field">
        <label>
          <input
            type="checkbox"
            v-model="matrix.is_public"
          />
          Is public
        </label>
      </div>
      <template v-if="matrix.id">
        <hr />
        <div>
          <VSwitch
            class="margin-small-bottom"
            :options="Object.values(MATRIX_VIEW)"
            v-model="matrixView"
          />
          <VSwitch
            :options="Object.values(MATRIX_MODE)"
            v-model="matrixMode"
          />
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { MATRIX_MODE, MATRIX_VIEW } from '../../const/modes'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import { computed } from 'vue'
import { useStore } from 'vuex'
import MatrixParent from './MatrixParent.vue'
import VSwitch from './switch.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()

const matrixName = computed({
  get: () => store.getters[GetterNames.GetMatrix].name,

  set: (value) => store.commit(MutationNames.SetMatrixName, value)
})

const matrix = computed({
  get: () => store.getters[GetterNames.GetMatrix],
  set: (value) => store.commit(MutationNames.SetMatrix, value)
})

const matrixView = computed({
  get: () => store.getters[GetterNames.GetMatrixView] === MATRIX_VIEW.Column,

  set(value) {
    store.commit(
      MutationNames.SetMatrixView,
      value ? MATRIX_VIEW.Column : MATRIX_VIEW.Row
    )
  }
})

const matrixMode = computed({
  get: () => store.getters[GetterNames.GetMatrixMode] === MATRIX_MODE.Fixed,
  set: (value) =>
    store.commit(
      MutationNames.SetMatrixMode,
      value ? MATRIX_MODE.Fixed : MATRIX_MODE.Dynamic
    )
})
</script>
