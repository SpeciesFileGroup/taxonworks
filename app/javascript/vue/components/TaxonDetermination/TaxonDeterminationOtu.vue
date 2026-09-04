<template>
  <fieldset class="separate-bottom">
    <legend>OTU</legend>
    <div class="horizontal-left-content separate-bottom align-end">
      <OtuAutoselectPicker
        preferences-key="otu_for_taxon_determination"
        @get-item="setOtu"
      />
      <lock-component
        v-if="lock !== undefined"
        class="margin-small-left"
        v-model="lockButton"
      />
    </div>
    <smart-selector-item
      :item="selectedOtu"
      @unset="unsetOtu"
    />
  </fieldset>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Otu } from '@/routes/endpoints'
import OtuAutoselectPicker from '@/components/otu/otu_picker/otu_autoselect_picker.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import LockComponent from '@/components/ui/VLock/index.vue'

const props = defineProps({
  modelValue: {
    type: Number,
    default: undefined
  },

  lock: {
    type: Boolean,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue', 'update:lock', 'label'])

const selectedOtu = ref(undefined)

const otuId = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const lockButton = computed({
  get: () => props.lock,
  set: (value) => emit('update:lock', value)
})

watch(otuId, (newId) => {
  if (newId) {
    if (newId !== selectedOtu.value?.id) {
      Otu.find(newId).then(({ body }) => {
        setOtu(body)
      })
    }
  } else {
    selectedOtu.value = undefined
  }
})

const setOtu = (otu) => {
  selectedOtu.value = otu
  otuId.value = otu.id
  emit('label', otu.object_tag)
}

const unsetOtu = () => {
  selectedOtu.value = undefined
  otuId.value = undefined
  emit('label', undefined)
}
</script>
