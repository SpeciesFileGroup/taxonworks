<template>
  <div>
    <div class="field label-above">
      <label>Buffered collecting event</label>
      <textarea
        class="full_width"
        rows="5"
        v-model="bufferedEvent"/>
    </div>
    <div class="field label-above">
      <label>Buffered determinations</label>
      <textarea
        class="full_width"
        rows="5"
        v-model="bufferedDeterminations"/>
    </div>
    <div class="field label-above">
      <label>Buffered other labels</label>
      <textarea
        class="full_width"
        rows="5"
        v-model="bufferedLabels"/>
    </div>
    <div class="horizontal-left-content">
      <div class="field label-above">
        <label>Total</label>
        <input
          class="input-xsmall-width"
          type="number"
          v-model="total">
      </div>
      <div class="field label-above margin-small-left full_width">
        <label>Preparation type</label>
        <select
          v-model="preparationId"
          class="normal-input full_width">
          <option
            class="full_width"
            v-for="item in types"
            :key="item.id"
            :value="item.id">
            {{ item.name }}
          </option>
        </select>
      </div>
    </div>
    <div class="field">
      <fieldset>
        <legend>Repository</legend>
        <smart-selector
          class="full_width"
          model="repositories"
          target="CollectionObject"
          klass="CollectionObject"
          pin-section="Repositories"
          pin-type="Repository"
          @selected="setRepository"/>
        <p
          v-if="labelRepository"
          class="horizontal-left-content">
          <span v-html="labelRepository"/>
          <span
            class="button circle-button btn-delete button-default"
            @click="unsetRepository"/>
        </p>
      </fieldset>
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

import Autocomplete from 'components/ui/Autocomplete.vue'
import SmartSelector from 'components/ui/SmartSelector'
import ToggleSwitch from './toggleSwitch.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { CollectingEvent, Repository, PreparationType } from 'routes/endpoints'

export default {
  components: {
    Autocomplete,
    ToggleSwitch,
    SmartSelector
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

  data () {
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

  mounted () {
    this.updateLabels()
    PreparationType.all().then(response => {
      this.types = response.body
    })
  },

  methods: {
    updateLabels () {
      this.labelRepository = this.labelEvent = undefined
      this.setEventLabel(this.eventId)
      this.setRepositoryLabel(this.repositoryId)
    },

    setEventLabel (id) {
      if (id) {
        CollectingEvent.find(id).then(response => {
          this.labelEvent = response.body.verbatim_label
        })
      }
    },

    setRepositoryLabel (id) {
      if (id) {
        Repository.find(id).then(response => {
          this.labelRepository = response.body.name
        })
      }
    },

    setRepository (repository) {
      this.labelRepository = repository.name
      this.repositoryId = repository.id
    },

    unsetRepository () {
      this.labelRepository = null
      this.repositoryId = null
    }
  }
}
</script>
