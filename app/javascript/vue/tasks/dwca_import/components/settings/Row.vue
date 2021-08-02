<template>
  <tr>
    <td v-html="displayData(row.institutionCode)"/>
    <td v-html="displayData(row.collectionCode)"/>
    <td
      class="full_width">
      <spinner-component
        v-if="isSaving"
        full-screen
        legend="Saving, please wait..."/>
      <template v-if="!namespace">
        <autocomplete
          class="full_width"
          placeholder="Search a namespace..."
          autofocus
          url="/namespaces/autocomplete"
          param="term"
          label="label_html"
          @getItem="setNamespace"/>
      </template>
      <template v-else>
        <div
          class="flex-separate middle">
          <span>{{ namespaceLabel }}</span>
          <span
            class="button circle-button btn-delete"
            @click="removeNamespace"/>
        </div>
      </template>
    </td>
  </tr>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { GetNamespace, UpdateCatalogueNumber } from '../../request/resources.js'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    Autocomplete,
    SpinnerComponent
  },
  computed: {
    namespaceLabel () {
      this.namespace ? `${this.namespace.name || this.namespace.label} (${this.namespace.short_name})` : ''
    }
  },
  props: {
    row: {
      type: Object,
      required: true
    },
    datasetId: {
      type: [String, Number]
    }
  },
  data () {
    return {
      namespace: undefined,
      edit: false,
      isSaving: false
    }
  },
  created () {
    if (this.row.namespace_id) {
      GetNamespace(this.row.namespace_id).then(response => {
        this.namespace = response.body
      })
    }
  },
  methods: {
    setNamespace (namespace) {
      this.namespace = namespace
      this.isSaving = true
      const data = {
        import_dataset_id: this.datasetId,
        institutionCode: this.row.institutionCode,
        collectionCode: this.row.collectionCode,
        namespace_id: namespace.id
      }
      UpdateCatalogueNumber(data).then((response) => {
        this.isSaving = false
        this.$emit('onUpdate', response.body)
      })
    },
    removeNamespace () {
      const data = {
        import_dataset_id: this.datasetId,
        institutionCode: this.row.institutionCode,
        collectionCode: this.row.collectionCode,
        namespace_id: null
      }
      this.isSaving = true
      UpdateCatalogueNumber(data).then(() => {
        this.isSaving = false
        this.namespace = undefined
        this.$emit('onRemove')
      })
    },
    displayData (data) {
      return data || '<i>(blank/undefined)</i>'
    }
  }
}
</script>
