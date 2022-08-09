<template>
  <div>
    <div class="horizontal-left-content full_width">
      <fieldset
        v-help.section.BibTeX.serial
        class="full_width">
        <legend>Serial</legend>
        <div class="horizontal-left-content align-start">
          <smart-selector
            class="full_width"
            input-id="serials-autocomplete"
            model="serials"
            target="Source"
            klass="Source"
            label="name"
            pin-section="Serials"
            pin-type="Serial"
            :filter-ids="serialId"
            @selected="setSelected"/>
          <lock-component
            class="margin-small-left"
            v-model="settings.lock.serial_id"/>
          <a
            class="margin-small-top margin-small-left"
            target="_blank"
            href="/serials/new">New</a>
        </div>
        <div
          class="middle separate-top"
          v-if="selected">
          <div class="horizontal-left-content">
            <span
              class="separate-right"
              v-html="selected.name"/>
            <radial-object :global-id="selected.global_id"/>
            <span
              class="button-circle btn-undo button-default separate-left"
              @click="unset"/>
          </div>
        </div>
      </fieldset>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { Serial } from 'routes/endpoints'

import LockComponent from 'components/ui/VLock/index.vue'
import SmartSelector from 'components/ui/SmartSelector'
import RadialObject from 'components/radials/navigation/radial'

export default {
  components: {
    SmartSelector,
    LockComponent,
    RadialObject
  },

  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    },

    serialId: {
      get () {
        return this.$store.getters[GetterNames.GetSerialId]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSerialId, value)
      }
    },

    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    }
  },

  data () {
    return {
      selected: undefined
    }
  },

  watch: {
    serialId: {
      handler (newVal, oldVal) {
        if (newVal) {
          if (oldVal !== newVal) {
            Serial.find(newVal).then(response => {
              this.selected = response.body
            })
          }
        }
        else {
          this.selected = undefined
        }
      },
      immediate: true,
      deep: true
    }
  },

  methods: {
    setSelected (serial) {
      this.source.serial_id = serial.id
      this.selected = serial
    },

    unset () {
      this.selected = undefined
      this.source.serial_id = null
    },

    getDefault (id) {
      Serial.find(id).then(response => {
        this.selected = response.body
      })
    }
  }
}
</script>
