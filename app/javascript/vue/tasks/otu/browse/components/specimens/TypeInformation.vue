<template>
  <div class="panel margin-small-bottom padding-small">
    <div
      @click="expand = !expand"
      class="cursor-pointer inline"
    >
      <div
        :data-icon="expand ? 'w-arrow-down' : 'w-arrow-right'"
        class="expand-box circle-button button-default"
      />
      <span class="margin-small-left">
        [<span
          v-html="
            types
              .map(
                (type) => `${type.type_type} of ${type.original_combination}`
              )
              .join('; ')
          "
        />] - <span v-html="ceLabel" />
      </span>
    </div>
    <template v-if="expand">
      <type-data
        class="species-information-container"
        v-for="type in types"
        :key="type.id"
        :type="type"
      />
      <specimen-information
        v-if="expand"
        class="species-information-container"
        :specimen="specimen"
      />
    </template>
  </div>
</template>

<script>
import SpecimenInformation from './SpecimenInformation'
import TypeData from './TypeData'

export default {
  components: {
    SpecimenInformation,
    TypeData
  },

  props: {
    specimen: {
      type: Object,
      required: true
    },

    types: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    ceLabel() {
      const tmp = []
      const levels = ['Country', 'State/Province', 'County']
      const verbatimLabel = this.specimen.verbatimLocality

      levels.forEach((level) => {
        const levelData = this.specimen[level]

        if (levelData) {
          tmp.push(`<b>${levelData}</b>`)
        }
      })

      if (verbatimLabel) {
        tmp.push(verbatimLabel)
      }

      return tmp.join('; ')
    }
  },

  data() {
    return {
      expand: false
    }
  }
}
</script>

<style scoped>
.species-information-container {
  margin-left: 20px;
}
</style>
