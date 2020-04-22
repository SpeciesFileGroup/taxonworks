<template>
  <fieldset>
    <legend>Buffered</legend>
    <pre ref="buffered">{{ collectionObject.buffered_collecting_event }}</pre>
  </fieldset>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

import { hyclas as Hyclas } from '@sfgrp/hyclas'

export default {
  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    },
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    },
    hyclasTypes () {
      return this.$store.getters[GetterNames.GetHyclasTypes]
    },
    fieldSelected () {
      return this.$store.getters[GetterNames.GetTypeSelected]
    }
  },
  data () {
    return {
      edit: false,
      hyclas: undefined,
      options: {
        types: []
      }
    }
  },
  watch: {
    fieldSelected (field) {
      this.hyclas.setType(field)
    }
  },
  mounted () {
    this.options.types = this.hyclasTypes
    this.hyclas = new Hyclas(this.$refs.buffered, this.options)
    this.$refs.buffered.addEventListener('createTag', this.setSelection)
    this.$refs.buffered.addEventListener('removeTag', this.removeSelection)
  },
  methods: {
    getSelectionHighlight () {
      const selection = window.getSelection().toString()
      if (this.settings.highlight && selection.length) {
        this.$store.commit(MutationNames.SetSelection, selection)
      }
    },
    setSelection (event) {
      const tag = event.detail
      this.$set(this.collectingEvent, tag.type, tag.label)
    },
    removeSelection (event) {
      const tag = event.detail
      this.$set(this.collectingEvent, tag.type, undefined)
    }
  },
  destroyed () {
    this.$refs.buffered.removeEventListener('createTag', this.setSelection)
    this.$refs.buffered.removeEventListener('removeTag', this.removeSelection)
  }
}
</script>
