<template>
  <div class="field">
    <label>Language</label>
    <div class="horizontal-left-content">
      <fieldset>
        <smart-selector
          model="languages"
          klass="source"
          label="name"
          @selected="setSelected"/>
        <div
          class="middle separate-top"
          v-if="selected">
          <span
            class="separate-right"
            v-html="selected.english_name"/>
          <span
            class="button-circle btn-undo button-default separate-left"
            @click="unset"/>
        </div>
      </fieldset>
      <lock-component v-model="settings.lock.language_id"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import LockComponent from 'components/lock'
import Autocomplete from 'components/autocomplete'
import SmartSelector from 'components/smartSelector'

import AjaxCall from 'helpers/ajaxCall'

export default {
  components: {
    SmartSelector,
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
  },
  watch: {
    source: {
      handler(newVal, oldVal) {
        if(newVal && newVal.language_id) {
          if(!oldVal || oldVal.language_id != newVal.language_id) {
            AjaxCall('get', `/languages/${newVal.language_id}`).then(response => {
              this.selected = response.body
            })
          }
        }
      },
      immediate: true
    }
  },
  data () {
    return {
      selected: undefined
    }
  },
  methods: {
    setSelected (language) {
      this.source.language_id = language.id
      this.selected = language
    },
    unset () {
      this.selected = undefined
      this.source.language_id = null
    }
  }
}
</script>
