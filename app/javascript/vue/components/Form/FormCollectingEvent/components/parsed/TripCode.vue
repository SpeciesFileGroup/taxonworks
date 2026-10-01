<template>
  <div>
    <h3>Field number</h3>
    <div class="flex-wrap-column middle align-start">
      <div class="full_width">
        <fieldset>
          <legend>Namespace</legend>
          <div class="horizontal-left-content align-start gap-small">
            <SmartSelector
              class="full_width"
              ref="smartSelector"
              model="namespaces"
              target="CollectingEvent"
              klass="CollectingEvent"
              v-model="store.namespace"
              @selected="setNamespace"
            />
            <WidgetNamespace @create="setNamespace" />
          </div>
          <template v-if="store.namespace">
            <SmartSelectorItem
              class="separate-top"
              :item="store.namespace"
              label="name"
              :unset-color="store.identifier.id ? 'destroy' : 'primary'"
              @unset="
                () =>
                  store.identifier.id
                    ? store.remove()
                    : (store.namespace = undefined)
              "
            />
          </template>
        </fieldset>
      </div>
      <div class="separate-top">
        <label>Identifier</label>
        <div class="horizontal-left-content field">
          <input
            type="text"
            v-model="store.identifier.identifier"
            @change="() => (store.identifier.isUnsaved = true)"
          />
          <label>
            <input
              type="checkbox"
              v-model="store.increment"
            />
            Increment
          </label>
        </div>
        <span
          v-if="!store.namespace && store.identifier.identifier"
          class="text-warning-color"
        >
          Namespace required: identifiers without a namespace will not be saved.
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'
import useStore from '../../store/identifier.js'

const store = useStore()

function setNamespace(namespace) {
  store.namespace = namespace
  store.identifier.isUnsaved = true
}
</script>
