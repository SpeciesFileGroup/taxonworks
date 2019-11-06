<template>
  <div class="field">
    <label>Serial</label>
    <div class="horizontal-left-content">
      <autocomplete
        class="separate-right"
        placeholder="Search a serial"
        url="/serials/autocomplete"
        param="term"
        label="label_html"
        display="label"
        @getItem="source.serial_id = $event.id"/>
      <lock-component v-model="settings.lock.serial_id"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import LockComponent from 'components/lock'
import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete,
    LockComponent
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
    }
  }
}
</script>
