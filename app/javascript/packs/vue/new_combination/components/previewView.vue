<template>
	<div class="new-combination-preview">
		<div class="header horizontal-center-content">
			<h3>Preview</h3>
		</div>
		<div class="content" v-if="combination">
			<h4 class="horizontal-center-content middle">
				<span>
					<i>
						<span 
							v-for="rank in combination" 
							v-if="rank"> {{ rank.name }}
						</span>
					</i>
					<span v-html="showAuthorCitation(searchLastExistingRank(combination))"></span>
				</span>				
			</h4>
		</div>
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
			searchLastExistingRank(combination) {
				return combination[Object.keys(combination).reverse().find((key) => {
					return combination[key]
				})]
			},
			showAuthorCitation(taxon) {
				return (taxon.hasOwnProperty('origin_citation') && taxon.origin_citation.hasOwnProperty('citation_source_body') ? taxon.origin_citation.citation_source_body : undefined)
			}
		}
	}
</script>
<style lang="scss" scoped>
	.header {
		h3 {
			font-weight: 300;
		}
		padding: 1em;
		padding-left: 1.5em;
		border-bottom: 1px solid #f5f5f5;
	}
</style>