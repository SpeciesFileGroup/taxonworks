<template>
  <div class="horizontal-left-content">
    <ul class="no_bullets context-menu">
      <li
        v-for="type in types"
        :key="type.value">
        <label>
          <input
            v-model="sourceType"
            :value="type.value"
            name="source-type"
            :disabled="source.id"
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

import LockComponent from 'components/lock'

export default {
  components: {
    LockComponent
  },
  computed: {
    source () {
      return this.$store.getters[GetterNames.GetSource]
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
  data () {
    return {
      types: [
        {
          label: 'BibTeX',
          value: 'Source::Bibtex'
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

<style>

</style>
