<template>
  <div>
    <div class="horizontal-left-content">
      <fieldset class="full_width">
        <legend>Language</legend>
        <div class="flex-separate align-start">
          <smart-selector
            class="full_width"
            model="languages"
            ref="smartSelector"
            klass="source"
            label="english_name"
            :filter-ids="languageId"
            @selected="setSelected"/>
          <lock-component
            class="margin-small-left"
            v-model="settings.lock.language_id"/>
        </div>
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
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import LockComponent from 'components/lock'
import SmartSelector from 'components/ui/SmartSelector'

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
    },
    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    },
    languageId: {
      get () {
        return this.$store.getters[GetterNames.GetLanguageId]
      },
      set (value) {
        this.$store.commit(MutationNames.SetLanguageId, value)
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
    },
    lastSave: {
      handler (newVal, oldVal) {
        if (newVal !== oldVal) {
          this.$refs.smartSelector.refresh()
        }
      }
    },
    languageId: {
      handler (newVal) {
        if(!newVal) {
          this.selected = undefined
        }
      }
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
