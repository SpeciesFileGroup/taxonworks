<template>
  <div>
    <label>Print label</label>
    <div class="flex-separate separate-bottom middle">
      <div>
        <button
          class="button normal-input button-default margin-small-right"
          @click="generateLabel"
        >
          Generate
        </button>
        <button
          @click="copyLabel"
          class="button normal-input button-default"
          type="button"
          :disabled="!isEmpty"
        >
          Copy verbatim label
        </button>
      </div>
      <label
        >Que to print
        <input
          class="que-input"
          :disabled="!(store.label.text && store.label.text.length)"
          size="5"
          v-model="store.label.total"
          type="number"
        />
      </label>
      <a
        v-if="store.label.id && store.label.total > 0"
        target="blank"
        :href="`/tasks/labels/print_labels?label_id=${store.label.id}`"
        >Preview
      </a>
    </div>
    <textarea
      v-model="store.label.text"
      cols="45"
      rows="12"
    />
    <label>Document label</label>
    <textarea
      v-model="collectingEvent.document_label"
      cols="45"
      rows="6"
    />
  </div>
</template>

<script setup>
import { parsedProperties } from '../../helpers/parsedProperties.js'
import { verbatimProperties } from '../../helpers/verbatimProperties.js'
import { sortArrayByArray } from '@/helpers/arrays.js'
import { computed } from 'vue'
import useStore from '../../store/collectingEvent.js'

const props = defineProps({
  componentsOrder: {
    type: Object,
    required: true
  }
})

const collectingEvent = defineModel()
const store = useStore()
const isEmpty = computed(() => store.label.text.length === 0)

function copyLabel() {
  store.label.text = collectingEvent.value.verbatim_label
}

function generateVerbatimLabel() {
  return props.componentsOrder.componentVerbatim
    .map((componentName) => ({
      [componentName]:
        typeof verbatimProperties[componentName] !== 'function'
          ? collectingEvent.value[verbatimProperties[componentName]]
          : verbatimProperties[componentName](collectingEvent.value)
    }))
    .filter((item) => item)
}

function generateParsedLabel() {
  return props.componentsOrder.componentParse
    .map((componentName) => ({
      [componentName]: parsedProperties[componentName]
    }))
    .filter((item) => Object.values(item)[0])
    .map((item) => {
      const [key, func] = Object.entries(item)[0]

      return {
        [key]: func({
          ce: collectingEvent.value,
          tripCode: store.tripCode,
          georeferences: [].concat(
            store.georeferences,
            store.queueGeoreferences
          ),
          unit: collectingEvent.unit || ''
        })
      }
    })
}

function generateLabel() {
  const objectLabels = Object.assign(
    {},
    ...generateVerbatimLabel(),
    ...generateParsedLabel()
  )

  const AtStart = ['TripIdentifier', 'TripCode']

  const sortedObjectLabelKeys = sortArrayByArray(
    Object.keys(objectLabels),
    AtStart
  )
  const sortedLabels = sortedObjectLabelKeys
    .map((key) => objectLabels[key])
    .filter(Boolean)

  store.label.text = [...new Set(sortedLabels)].join('\n')
}
</script>
<style scoped>
textarea {
  width: 100%;
}
.que-input {
  width: 50px;
}
</style>
