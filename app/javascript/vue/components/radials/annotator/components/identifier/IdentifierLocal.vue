<template>
  <div>
    <div>
      <fieldset>
        <legend>Namespace</legend>
        <div class="horizontal-left-content align-start gap-small">
          <SmartSelector
            model="namespaces"
            :klass="objectType"
            pin-section="Namespaces"
            pin-type="Namespace"
            @selected="(item) => (namespace = item)"
          >
          </SmartSelector>
          <WidgetNamespace @create="(item) => (namespace = item)" />
        </div>
        <SmartSelectorItem
          :item="namespace"
          label="name"
          @unset="namespace = undefined"
        />
      </fieldset>
      <div class="field separate-top">
        <input
          class="normal-input full_width"
          placeholder="Identifier"
          type="text"
          v-model="identifier"
        />
      </div>
    </div>
    <button
      type="button"
      class="button normal-input button-submit separate-bottom"
      :disabled="!validateFields"
      @click="emitCreate"
    >
      Create
    </button>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'

const props = defineProps({
  objectType: {
    type: String,
    required: true
  },

  type: {
    type: [String, null],
    required: true
  }
})

const namespace = ref(null)
const identifier = ref(null)
const emit = defineEmits(['create'])

const validateFields = computed(
  () => identifier.value && namespace.value?.id && props.type
)

const emitCreate = () => {
  emit('create', {
    namespace_id: namespace.value.id,
    identifier: identifier.value
  })
}
</script>
