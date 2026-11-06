<template>
  <div>
    <label>Otu</label>
    <SmartSelectorItem
      v-if="otu"
      :item="otu"
      @unset="matrix.otu_id = null"
    />
    <AutoselectPicker
      v-else
      model="otus"
      param="otu_id"
      get-object
      preferences-key="otu_for_observation_matrix_parent"
      @select="setOtu"
    />
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { Otu } from '@/routes/endpoints'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import { ref, watch } from 'vue'
import AutoselectPicker from '@/components/ui/AutoselectPicker.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const store = useStore()
const otu = ref(null)

const matrix = computed({
  get: () => store.getters[GetterNames.GetMatrix],
  set: (value) => store.commit(MutationNames.SetMatrix, value)
})

watch(
  () => matrix.value.otu_id,
  (id) => {
    if (id) {
      if (otu.value?.id !== id) {
        Otu.find(id).then(({ body }) => {
          otu.value = body
        })
      }
    } else {
      otu.value = null
    }
  }
)

function setOtu(item) {
  otu.value = item
  matrix.value.otu_id = item.id
}
</script>
