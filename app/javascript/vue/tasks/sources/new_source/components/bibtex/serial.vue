<template>
  <div>
    <div class="horizontal-left-content full_width">
      <fieldset class="full_width">
        <legend>Serial</legend>
        <div class="horizontal-left-content align-start">
          <smart-selector
            class="full_width"
            ref="smartSelector"
            input-id="serials-autocomplete"
            model="serials"
            target="Source"
            klass="Source"
            label="name"
            pin-section="Serials"
            pin-type="Serial"
            @selected="setSelected"/>
          <div class="horizontal-right-content padding-medium-right">
            <lock-component
              class="circle-button"
              v-model="settings.lock.serial_id"/>
          </div>
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
      <div class="vertical-content">
        
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import LockComponent from 'components/lock'
import SmartSelector from 'components/smartSelector'
import RadialObject from 'components/radials/navigation/radial'

import AjaxCall from 'helpers/ajaxCall'

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
    source: {
      handler(newVal, oldVal) {
        if(newVal && newVal.serial_id) {
          if(!oldVal || oldVal.serial_id != newVal.serial_id) {
            AjaxCall('get', `/serials/${newVal.serial_id}.json`).then(response => {
              this.selected = response.body
            })
          }
        }
      },
      immediate: true
    },
    lastSave: {
      handler (newVal, oldVal) {
        if (newVal !== oldVal) {
          this.$refs.smartSelector.refresh()
        }
      }
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
      AjaxCall('get', `/serials/${id}.json`).then(response => {
        this.selected = response.body
      })
    }
  }
}
</script>
