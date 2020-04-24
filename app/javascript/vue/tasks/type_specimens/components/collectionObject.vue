<template>
  <div>
    <div class="field types_field">
      <label>Buffered collecting event</label>
      <textarea
        rows="5"
        v-model="bufferedEvent"/>
    </div>
    <div class="field types_field">
      <label>Buffered determinations</label>
      <textarea
        rows="5"
        v-model="bufferedDeterminations"/>
    </div>
    <div class="field types_field">
      <label>Buffered other labels</label>
      <textarea
        rows="5"
        v-model="bufferedLabels"/>
    </div>
    <div class="field">
      <label>Total</label>
      <input
        type="number"
        v-model="total">
    </div>
    <div class="field">
      <label>Preparation type</label>
      <select
        v-model="preparationId"
        class="normal-input">
        <option
          v-for="item in types"
          :value="item.id">{{ item.name }}</option>
      </select>
    </div>
    <div class="field">
      <label>Repository</label>
      <autocomplete
        class="types_field"
        url="/repositories/autocomplete"
        param="term"
        label="label_html"
        :send-label="labelRepository"
        placeholder="Select a repository"
        @getItem="repositoryId = $event.id; labelRepository = $event.label"
        display="label"
        min="2"/>
    </div>
    <div class="field">
      <label>Collection event</label>
      <autocomplete
        class="types_field"
        url="/collecting_events/autocomplete"
        param="term"
        label="label_html"
        :send-label="labelEvent"
        placeholder="Select a collection event"
        @getItem="eventId = $event.id; labelEvent = $event.label"
        display="label"
        min="2"/>
    </div>
    <div class="field">
      <toggle-switch :biological-id="biologicalId"/>
    </div>
  </div>
</template>

<script>

import autocomplete from 'components/autocomplete.vue'
import toggleSwitch from './toggleSwitch.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { GetCollectionEvent, GetRepository, GetPreparationTypes } from '../request/resources'

export default {
  components: {
    autocomplete,
    toggleSwitch
  },
  computed: {
    typeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },
    biologicalId () {
      return this.$store.getters[GetterNames.GetBiologicalId]
    },
    repositoryId: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject].repository_id
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectRepositoryId, value)
      }
    },
    bufferedDeterminations: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObjectBufferedDeterminations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedDeterminations, value)
      }
    },
    bufferedEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObjectBufferedEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedEvent, value)
      }
    },
    bufferedLabels: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObjectBufferedLabels]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedLabels, value)
      }
    },
    eventId: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObjectCollectionEventId]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectEventId, value)
      }
    },
    preparationId: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObjectPreparationId]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectPreparationId, value)
      }
    },
    total: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObjectTotal]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectTotal, value)
      }
    }
  },
  data: function () {
    return {
      types: [],
      labelRepository: undefined,
      labelEvent: undefined
    }
  },
  watch: {
    biologicalId: {
      handler (newVal) {
        if (newVal) {
          this.updateLabels()
        }
      }
    },
    repositoryId: {
      handler (newVal) {
        if(!newVal) {
          this.labelRepository = ''
        }
      },
      deep: true
    }
  },
  mounted: function () {
    this.updateLabels()
    GetPreparationTypes().then(response => {
      this.types = response
    })
  },
  methods: {
    updateLabels () {
      this.labelRepository = this.labelEvent = undefined
      this.setEventLabel(this.eventId)
      this.setRepositoryLabel(this.repositoryId)
    },
    sendEvent () {
      this.$emit('send')
    },
    setEventLabel (id) {
      if (id) {
        GetCollectionEvent(id).then(response => {
          this.labelEvent = response.verbatim_label
        })
      }
    },
    setRepositoryLabel (id) {
      if (id) {
        GetRepository(id).then(response => {
          this.labelRepository = response.name
        })
      }
    }
  }
}
</script>
