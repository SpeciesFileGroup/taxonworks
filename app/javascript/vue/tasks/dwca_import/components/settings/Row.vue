<template>
  <tr>
    <td>{{ row.institutionCode }}</td>
    <td>{{ row.collectionCode }}</td>
    <td
      v-if="!namespace"
      class="full_width">
      <autocomplete
        class="full_width"
        placeholder="Search a namespace..."
        autofocus
        url="/namespaces/autocomplete"
        param="term"
        label="label"
        @getItem="setNamespace"/>
    </td>
    <td v-else>
      <div
        class="flex-separate middle">
        <span>{{ namespaceLabel }}</span>
        <span
          class="button circle-button btn-delete"
          @click="removeNamespace"/>
      </div>
    </td>
  </tr>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { GetNamespace, UpdateCatalogueNumber } from '../../request/resources.js'

export default {
  components: {
    Autocomplete
  },
  computed: {
    namespaceLabel () {
      return this.namespace ? this.namespace.name || this.namespace.label : ''
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
      edit: false
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
      const data = {
        import_dataset_id: this.datasetId,
        institutionCode: this.row.institutionCode,
        collectionCode: this.row.collectionCode,
        namespace_id: namespace.id
      }
      UpdateCatalogueNumber(data)
    },
    removeNamespace () {
      const data = {
        import_dataset_id: this.datasetId,
        institutionCode: this.row.institutionCode,
        collectionCode: this.row.collectionCode,
        namespace_id: null
      }
      UpdateCatalogueNumber(data).then(() => {
        this.namespace = undefined
      })
    }
  }
}
</script>
