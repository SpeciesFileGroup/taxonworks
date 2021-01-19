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
          :disabled="!isEmpty">
          Copy verbatim label
        </button>
      </div>
      <label>Que to print
        <input
          class="que-input"
          :disabled="!(label.text && label.text.length)"
          size="5"
          v-model="label.total"
          type="number">
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
      rows="6"/>
  </div>
</template>

<script>
import extendCE from '../mixins/extendCE.js'
import DOMPurify from 'dompurify'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

const verbatimProperties = {
  Label: 'verbatim_label',
  Locality: 'verbatim_locality',
  Latitude: 'verbatim_latitude',
  Longitude: 'verbatim_longitude',
  Geolocation: 'verbatim_geolocation_uncertainty',
  Habitat: 'verbatim_habitat',
  DateComponent: 'verbatim_date',
  Collectors: 'verbatim_collectors',
  Method: 'verbatim_method',
  TripIdentifier: 'verbatim_trip_identifier'
}

const romanNumbers = ['i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x', 'xi', 'xii']

const parsedProperties = {
  GeographicArea: ({ ce }) => ce.geographicArea?.name,

  Dates: ({ ce }) => [
    [
      ce.start_date_day,
      romanNumbers[Number(ce.start_date_month) - 1],
      ce.start_date_year],
    [
      ce.end_date_day,
      romanNumbers[Number(ce.end_date_month) - 1],
      ce.end_date_year
    ]
  ].map(dates => dates.filter(date => date).join('.')).filter(arr => arr.length).join('\n'),

  Elevation: ({ ce }) => [
    ce.minimum_elevation,
    ce.maximum_elevation,
    ce.elevation_precision
  ].filter(item => item).map(item => `${item}m`).join(' '),

  Time: ({ ce }) => [
    [
      ce.time_start_hour,
      ce.time_start_minute,
      ce.time_start_second
    ],
    [
      ce.time_end_hour,
      ce.time_end_minute,
      ce.time_end_second
    ]
  ].map(times =>
    times.filter(time => time).map(time => time < 10 ? `0${time}` : time).join(':')).filter(arr => arr.length).join('\n'),

  CollectorsComponent: ({ ce }) => ce.roles_attributes.map(role => role.person.cached).join('; '),

  TripCode: ({ ce, tripCode }) => DOMPurify.sanitize(tripCode.object_tag, { FORBID_TAGS: ['span'], KEEP_CONTENT: true })
}

export default {
  mixins: [extendCE],
  computed: {
    isEmpty () {
      return this.label.text.length === 0
    },
    label: {
      get () {
        return this.$store.getters[GetterNames.GetCELabel]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCELabel, value)
      }
    },
    tripCode () {
      return this.$store.getters[GetterNames.GetIdentifier]
    }
  },
  methods: {
    copyLabel () {
      this.label.text = this.collectingEvent.verbatim_label
    },
    generateVerbatimLabel () {
      return this.componentsOrder.componentVerbatim.map(componentName => this.collectingEvent[verbatimProperties[componentName]]).filter(item => item)
    },
    generateParsedLabel () {
      return this.componentsOrder.componentParse.map(componentName => parsedProperties[componentName]).filter(func => func).map(func => func(Object.assign({}, { ce: this.collectingEvent, tripCode: this.tripCode })))
    },
    generateLabel () {
      this.label.text = [].concat(this.generateVerbatimLabel(), this.generateParsedLabel().filter(label => label)).join('\n')
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
