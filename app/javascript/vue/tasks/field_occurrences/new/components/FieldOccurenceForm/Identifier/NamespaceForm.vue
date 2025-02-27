<template>
  <fieldset>
    <legend>Namespace</legend>
    <SmartSelector
      class="full_width separate-bottom"
      model="namespaces"
      input-id="namespace-autocomplete"
      :target="FIELD_OCCURRENCE"
      :klass="FIELD_OCCURRENCE"
      pin-section="Namespaces"
      pin-type="Namespace"
      v-model="namespace"
      @selected="(item) => (updateNamespace(item))"
    >
      <template #tabs-right>
        <VLock v-model="settings.locked.namespace" />

        <WidgetNamespace @create="(item) => (updateNamespace(item))" />
      </template>
    </SmartSelector>
    <template v-if="namespace">
      <hr />
      <SmartSelectorItem
        :item="namespace"
        label="name"
        @click="() => (updateNamespace(undefined))"
      />
    </template>
  </fieldset>
</template>

<script setup>
import { FIELD_OCCURRENCE } from '@/constants/index.js'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'
import useSettingStore from '../../../store/settings.js'

const emit = defineEmits(['selected'])

const namespace = defineModel({
  type: Object,
  default: undefined
})

const settings = useSettingStore()

function updateNamespace(newNamespace) {
  namespace.value = newNamespace
  emit('selected')
}
</script>
