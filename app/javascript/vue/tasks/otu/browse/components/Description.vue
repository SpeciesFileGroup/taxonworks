<template>
  <section-panel
    :status="status"
    :title="title">
    <div>
      {{ generatedDescription }}
    </div>
  </section-panel>
</template>

<script>
import SectionPanel from './shared/sectionPanel'
import extendSection from './shared/extendSections'
import ajaxCall from 'helpers/ajaxCall'

export default {
  mixins: [extendSection],

  components: { SectionPanel },

  props: {
    otu: {
      type: Object,
      required: true
    }
  },

  data: () => ({
    generatedDescription: ''
  }),

  watch: {
    otu: {
      handler (newVal) {
        if (newVal?.id) {
          this.loadDescription()
        }
      },
      immediate: true
    }
  },

  methods: {
    loadDescription () {
      const urlParams = new URLSearchParams(window.location.search)
      const matrixId = urlParams.get('observation_matrix_id')

      ajaxCall('get', '/tasks/observation_matrices/description_from_observation_matrix/description', {
        params: {
          otu_id: this.otu.id,
          include_descendants: true,
          observation_matrix_id: /^\d+$/.test(matrixId)
            ? matrixId
            : undefined
        }
      }).then(({ body }) => {
        this.generatedDescription = body.generated_description
      })
    }
  }

}
</script>
