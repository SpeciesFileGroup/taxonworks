<template>
  <div>
    <h2>Trip code</h2>
    <div class="flex-wrap-column middle align-start">
      <div class="full_width">
        <fieldset>
          <legend>Namespace</legend>
          <smart-selector
            class="full_width"
            ref="smartSelector"
            model="namespaces"
            target="CollectingEvent"
            klass="CollectingEvent"
            v-model="namespace"
            @selected="setNamespace"
          />
          <template v-if="store.tripCode.namespace_id && namespace">
            <div class="middle separate-top">
              <span data-icon="ok" />
              <p
                class="separate-right"
                v-html="namespace.name"
              />
              <span
                v-if="store.tripCode.id"
                @click="removeIdentifier"
                class="circle-button btn-delete"
              />
              <span
                v-else
                class="circle-button button-default btn-undo"
                @click="unsetIdentifier"
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
            v-model="store.tripCode.identifier"
          />
          <label>
            <input
              type="checkbox"
              v-model="store.incrementIdentifier"
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
import { ref, watch } from 'vue'
import { Namespace, Identifier } from '@/routes/endpoints'
import useStore from '../../store/collectingEvent'

const store = useStore()
const namespace = ref()

watch(store.tripCode.namespace_id, (newVal) => {
  if (newVal) {
    Namespace.find(newVal).then((response) => {
      namespace.value = response.body
    })
  } else {
    namespace.value = undefined
  }
})

function setNamespace(namespace) {
  store.tripCode.namespace_id = namespace.id
}

function unsetIdentifier() {
  store.tripCode.namespace_id = undefined
  store.tripCode.identifier = undefined
  namespace.value = undefined
}

function removeIdentifier() {
  Identifier.destroy(store.tripCode.id).then(() => {
    unsetIdentifier()
  })
}
</script>
