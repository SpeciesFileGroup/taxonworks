<template>
  <div>
    <h3>Identifier</h3>
    <fieldset>
      <legend>Namespace</legend>
      <div
        class="horizontal-left-content align-start separate-bottom full_width gap-small"
      >
        <SmartSelector
          class="full_width"
          ref="smartSelector"
          model="namespaces"
          target="CollectionObject"
          klass="CollectionObject"
          pin-section="Namespaces"
          pin-type="Namespace"
          @selected="setNamespace"
        />
        <WidgetNamespace @create="setNamespace" />
      </div>
      <template v-if="identifier.namespace">
        <div class="middle separate-top">
          <span data-icon="ok" />
          <p
            class="separate-right"
            v-html="identifier.namespace.name"
          />
          <span
            class="circle-button button-default btn-undo"
            @click="identifier.namespace = undefined"
          />
        </div>
      </template>
    </fieldset>
    <p>Catalogue number</p>
    <div class="horizontal-left-content full_width">
      <div class="field label-above full_width">
        <label>Start</label>
        <input
          class="full_width"
          type="text"
          v-model.number="identifier.start"
        />
      </div>
      <div class="field label-above margin-small-left full_width">
        <label>End</label>
        <input
          disabled
          class="full_width"
          :value="end"
          type="text"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'

const props = defineProps({
  count: {
    type: Number,
    default: 0
  }
})

const identifier = defineModel({ type: Object, required: true })
const end = computed(() =>
  Number.isInteger(identifier.value.start)
    ? identifier.value.start + props.count
    : ''
)

function setNamespace(namespace) {
  identifier.value.namespace = namespace
}
</script>

<style scoped>
.validate-identifier {
  border: 1px solid red;
}
</style>
