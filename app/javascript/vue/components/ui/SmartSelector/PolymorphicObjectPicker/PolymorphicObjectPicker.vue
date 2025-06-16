<template>
  <div>
    <VSpinner
      v-if="loading"
    />

    <div class="horizontal-left-content separate-bottom">
      <VSwitch
        :options="tabDisplayOptions"
        v-model="tab"
      />
      <slot name="tabs-right" />
    </div>

    <div v-if="minimal">
      <VAutocomplete
        :url="`/${tabData['snake']}/autocomplete`"
        :placeholder="`Search for a ${tabData['singular']}`"
        label="label_html"
        clear-after
        param="term"
        :autofocus="autofocus"
        @get-item="(item) => sendObjectFromId(item.id)"
        class="separate-bottom"
      />
    </div>

    <div v-else>
      <SmartSelector
        v-model="selectorModelObject"
        :placeholder="`Search for a ${tabData['human']}`"
        :model="tabData['snake']"
        klass="AssertedDistribution"
        target="AssertedDistribution"
        label="name"
        ref="smartSelector"
        inline
        buttons
        :autofocus="autofocus"
        :pin-section="tabData['plural']"
        :pin-type="tabData['singular']"
        @selected="(object) => sendObject(object)"
      />
    </div>

  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VSwitch from '@/components/ui/VSwitch.vue'

const props = defineProps({
  objectTypes: {
    type: Array,
    required: true
  },

  minimal: {
    type: Boolean,
    default: false
  },

  focusOnSelect: {
    type: Boolean,
    default: false
  },

  autofocus: {
    type: Boolean,
    default: false
  }
})

const inputObject = defineModel({
  type: Object,
  default: () => ({})
})

const smartSelector = ref(null)
const tab = ref(props.objectTypes[0]['display'])
const loading = ref(false)

const emit = defineEmits(['selectObject'])

const tabData = computed(() => {
  return props.objectTypes.find((o) => o['display'] == tab.value)
})

const tabDisplayOptions = computed(() => {
  return props.objectTypes.map((o) => o['display'])
})

// inputObject gets passed on to the selector if they have the same object type;
// object assigned from the selector *always* gets passed back to inputObject.
const selectorModelObject = computed({
  get() {
    return inputObject.value?.objectType == tab.value
      ? inputObject.value
      : {}
  },
  set(value) {
    value.meta = tabData.value
    inputObject.value = value
  }
})

function sendObjectFromId(id) {
  tabData.value['endpoint'].find(id)
    .then(({ body }) => {
      sendObject(body)
    })
    .catch(() => {})
}

function sendObject(object) {
  object.objectType = tabData.value['singular']
  emit('selectObject', object)
  if (props.focusOnSelect) {
    smartSelector.value?.setFocus()
  }
}

</script>
