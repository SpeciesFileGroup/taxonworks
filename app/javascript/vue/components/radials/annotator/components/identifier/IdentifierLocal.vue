<template>
  <div>
    <div>
      <fieldset>
        <legend>Namespace</legend>
        <smart-selector
          class="margin-medium-top"
          model="namespaces"
          :klass="objectType"
          pin-section="Namespaces"
          pin-type="Namespace"
          @selected="namespace = $event"
        >
          <SmartSelectorItem
            :item="namespace"
            label="name"
            @unset="namespace = undefined"
          />
        </smart-selector>
      </fieldset>
      <div class="field separate-top">
        <input
          class="normal-input full_width"
          placeholder="Identifier"
          type="text"
          v-model="identifier"
        >
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
import SmartSelector from 'components/ui/SmartSelector'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'

const props = defineProps({
  objectType: {
    type: String,
    required: true
  },

  type: {
    type: String,
    required: true
  }
})

const namespace = ref(null)
const identifier = ref(null)
const emit = defineEmits(['create'])

const validateFields = computed(() =>
  identifier.value &&
  namespace.value?.id &&
  props.type
)

const emitCreate = () => {
  emit('create', {
    namespace_id: namespace.value.id,
    identifier: identifier.value
  })
}

</script>
