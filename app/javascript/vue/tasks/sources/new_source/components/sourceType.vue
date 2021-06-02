<template>
  <div class="horizontal-left-content field-options">
    <ul class="no_bullets context-menu">
      <li
        v-for="type in types"
        :key="type.value">
        <label v-help="`section.sourceType.${type.label}`">
          <input
            v-model="sourceType"
            :value="type.value"
            name="source-type"
            :disabled="source.id && (!type.available || !type.available.includes(source.type))"
            type="radio">
          {{ type.label }}
        </label>
      </li>
    </ul>
    <div class="separate-left">
      <lock-component v-model="settings.lock.type"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

import LockComponent from 'components/ui/VLock/index.vue'
import NewSource from '../const/source.js'

export default {
  components: {
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
    sourceType: {
      get () {
        return this.$store.getters[GetterNames.GetType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetType, value)
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
    sourceType (newVal) {
      if (!this.source.id) {
        const newSource = NewSource()
        newSource.type = newVal
        this.source = newSource
      }
    }
  },
  data () {
    return {
      types: [
        {
          label: 'BibTeX',
          value: 'Source::Bibtex',
          available: ['Source::Verbatim']
        },
        {
          label: 'Verbatim',
          value: 'Source::Verbatim'
        },
        {
          label: 'Person',
          value: 'Source::Human'
        }
      ]
    }
  }
}
</script>

<style scoped>
  .field-options {
    width: 390px;
  }
</style>
