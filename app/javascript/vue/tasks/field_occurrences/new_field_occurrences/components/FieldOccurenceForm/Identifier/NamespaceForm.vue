<template>
  <fieldset>
    <legend>Namespace</legend>
    <div class="horizontal-left-content align-start separate-bottom">
      <SmartSelector
        class="full_width"
        model="namespaces"
        input-id="namespace-autocomplete"
        :target="FIELD_OCCURRENCE"
        :klass="FIELD_OCCURRENCE"
        pin-section="Namespaces"
        pin-type="Namespace"
        v-model="namespace"
        @selected="(item) => (namespace = item)"
      />
      <a
        class="margin-small-top margin-small-left"
        href="/namespaces/new"
        >New</a
      >
    </div>
    <template v-if="namespace">
      <hr />
      <div class="middle flex-separate">
        <p class="separate-right">
          <span data-icon="ok" />
          <span v-html="namespace.name" />
        </p>
        <span
          class="circle-button button-default btn-undo"
          @click="() => (namespace = undefined)"
        />
      </div>
    </template>
  </fieldset>
</template>

<script setup>
import { FIELD_OCCURRENCE } from '@/constants/index.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'

const namespace = defineModel({
  type: Object,
  default: undefined
})
</script>
