<template>
  <span
    class="circle-button button-default btn-hexagon-arrow-flip-w"
    title="Browse nomenclature"
    @click="redirect()"
    @contextmenu.prevent="redirect(true)"
  >Otu
  </span>
</template>

<script>

import ajaxCall from 'helpers/ajaxCall'

export default {
  props: {
    objectId: {
      type: [String, Number],
      required: true
    },
    klass: {
      type: String,
      default: 'TaxonName'
    }
  },
  data () {
    return {
      isLoading: false
    }
  },
  methods: {
    redirect (newTab) {
      if (this.isLoading) return

      this.isLoading = true
      if (this.klass === 'TaxonName') {
        this.openBrowse(this.objectId, newTab)
      } else {
        ajaxCall('get', `/otus/${this.objectId}.json`).then(response => {
          if (response.body.length) {
            this.openBrowse(response.body[0].taxon_name_id, newTab)
          }
        })
      }
    },
    openBrowse (id, newTab = false) {
      window.open(`/tasks/nomenclature/browse?taxon_name_id=${id}`, newTab ? '_blank' : '_self')
    }
  }
}
</script>
