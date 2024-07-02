<template>
  <div>
    <h2>Trip code</h2>
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
            <div class="middle separate-top">
              <span data-icon="ok" />
              <p
                class="separate-right"
                v-html="store.namespace.name"
              />
              <span
                v-if="store.identifier.id"
                class="circle-button btn-delete"
                @click="store.remove"
              />
              <span
                v-else
                class="circle-button button-default btn-undo"
                @click="() => (store.namespace = undefined)"
              />
            </div>
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
      </div>
    </div>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'
import useStore from '../../store/identifier.js'

const store = useStore()

function setNamespace(namespace) {
  store.namespace = namespace
  store.identifier.isUnsaved = true
}
</script>
