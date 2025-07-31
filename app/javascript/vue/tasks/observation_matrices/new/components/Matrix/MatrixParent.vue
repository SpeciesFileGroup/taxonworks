<template>
  <div>
    <label>Otu</label>
    <SmartSelectorItem
      v-if="otu"
      :item="otu"
      @unset="matrix.otu_id = null"
    />
    <VAutocomplete
      v-else
      class="full_width"
      url="/otus/autocomplete"
      placeholder="Search an OTU..."
      label="label_html"
      :input-style="{ width: '100%' }"
      clear-after
      param="term"
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
import VAutocomplete from '@/components/ui/Autocomplete.vue'
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
  otu.value = { id: item.id, object_tag: item.label_html }
  matrix.value.otu_id = item.id
}
</script>
