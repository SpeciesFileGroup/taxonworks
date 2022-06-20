<template>
  <div>
    <label>Print label</label>
    <div class="flex-separate separate-bottom middle">
      <div>
        <button
          class="button normal-input button-default margin-small-right"
          @click="generateLabel">
          Generate
        </button>
        <button
          @click="copyLabel"
          class="button normal-input button-default"
          type="button"
          :disabled="!verbatimLabel"
        >
          Copy verbatim label
        </button>
      </div>
      <label>Que to print
        <input
          class="que-input"
          :disabled="!(label.text && label.text.length)"
          size="5"
          v-model="label.total"
          type="number"
        >
      </label>
      <a
        v-if="label.id && label.total > 0"
        target="blank"
        :href="`/tasks/labels/print_labels?label_id=${label.id}`">Preview
      </a>
    </div>
    <textarea
      v-model="label.text"
      cols="45"
      rows="12"/>
    <label>Document label</label>
    <textarea
      v-model="collectingEvent.document_label"
      cols="45"
      rows="6"
    />
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'
import { parsedProperties } from 'tasks/collecting_events/new_collecting_event/helpers/parsedProperties.js'
import { verbatimProperties } from 'tasks/collecting_events/new_collecting_event/helpers/verbatimProperties.js'
import { sortArrayByArray } from 'helpers/arrays.js'
import expandCE from '../../mixins/extendCE'

export default {
  mixins: [expandCE],

  computed: {
    label: {
      get () {
        return this.$store.getters[GetterNames.GetLabel]
      },
      set (value) {
        this.$store.commit(MutationNames.SetLabel, value)
      }
    },

    verbatimLabel () {
      return this.$store.getters[GetterNames.GetCollectingEvent].verbatim_label
    },

    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    },

    preferences () {
      return this.$store.getters[GetterNames.GetPreferences]
    },

    componentsOrder () {
      return this.$store.getters[GetterNames.GetComponentsOrder]
    },

    tripCode () {
      return this.$store.getters[GetterNames.GetCollectingEventIdentifier]
    }
  },

  methods: {
    copyLabel () {
      this.label.text = this.verbatimLabel
    },

    generateVerbatimLabel () {
      return this.componentsOrder.ComponentVerbatim
        .map(componentName => ({ [componentName]: this.collectingEvent[verbatimProperties[componentName]] }))
        .filter(item => Object.values(item)[0])
    },

    generateParsedLabel () {
      return this.componentsOrder.ComponentParse
        .map(componentName => ({ [componentName]: parsedProperties[componentName] }))
        .filter(item => Object.values(item)[0])
        .map(item => {
          const [key, func] = Object.entries(item)[0]

          return {
            [key]: func({ ce: this.collectingEvent, tripCode: this.tripCode })
          }
        }
      )
    },

    generateLabel () {
      const objectLabels = Object.assign({},
        ...this.generateVerbatimLabel(),
        ...this.generateParsedLabel()
      )

      const AtStart = [
        'TripIdentifier',
        'TripCode',
      ]

      const sortedObjectLabelKeys = sortArrayByArray(Object.keys(objectLabels), AtStart)
      const sortedLabels = sortedObjectLabelKeys.map(key => objectLabels[key]).filter(Boolean)

      this.label.text = [...new Set(sortedLabels)].join('\n')
    }
  }
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
