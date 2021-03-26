<template>
  <div>
    <autocomplete
      class="field"
      url="/documents/autocomplete"
      label="label"
      min="2"
      placeholder="Select a document"
      clear-after
      @getItem="createNew"
      param="term"
    />
  </div>
</template>

<script>

import { CreateDocumentation } from '../../request/resources'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'
import Autocomplete from 'components/autocomplete'

export default {
  components: { Autocomplete },

  props: {
    source: {
      type: Object,
      required: true
    }
  },

  computed: {
    list: {
      get () {
        return this.$store.getters[GetterNames.GetDocumentations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDocumentations, value)
      }
    }
  },

  methods: {
    createNew (document) {
      this.$store.dispatch(ActionNames.SaveDocumentation, {
        document_id: document.id,
        annotated_global_entity: decodeURIComponent(this.source.global_id)
      })
    }
  }
}
</script>
