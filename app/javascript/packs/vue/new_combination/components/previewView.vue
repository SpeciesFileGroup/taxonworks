<template>
  <div class="new-combination-preview header">
    <h3 class="horizontal-center-content" v-if="combination">
      <span>
        <i>
          <span
            v-for="rank in reverse(combination)"
            v-if="combination[rank]"> {{ combination[rank].name }}
          </span>
        </i>
        <span v-html="showAuthorCitation(searchLastExistingRank(combination))"/>
      </span>
    </h3>
  </div>
</template>
<script>
export default {
  props: {
    combination: {
      type: Object,
      default: undefined
    }
  },
  methods: {
    searchLastExistingRank (combination) {
      return combination[Object.keys(combination).find((key) => {
        return combination[key]
      })]
    },
    showAuthorCitation (taxon) {
      return (taxon.hasOwnProperty('origin_citation') && taxon.origin_citation.hasOwnProperty('citation_source_body') ? taxon.origin_citation.citation_source_body : undefined)
    },
    reverse (value) {
      return Object.keys(value).splice(0).reverse()
    }
  }
}
</script>
<style lang="scss" scoped>
	.new-combination-preview {
		position: relative;
		.new-combination-preview-edit {
			position: absolute;
			right: 12px;
		}
	}
	.header {
		align-items: center;
		h3 {
			font-weight: 300;
		}
		padding: 1em;
		padding-left: 1.5em;
		border-left: none;

		border-bottom: 1px solid #f5f5f5;
	}
</style>
