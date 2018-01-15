<template>
	<div>
		<h4 class="capitalize">{{ rankName }}</h4>
		<ul>
			<li class="no_bullets" v-for="taxon in list">
				<label class="middle">
					<input type="radio" v-model="rankChoose" :value="taxon"/>
					<span v-html="taxon.object_tag"></span>
				</label>
			</li>
		</ul>
	</div>
</template>
<script>

	export default {
		props: {
			list: { 
				type: Array,
				required: true
			},
			rankName: {
				type: String
			},
			selected: {
				type: Object
			},
		},
		computed: {
			rankChoose: {
				get() {
					return this.selected
				},
				set(taxon) {
					this.selectTaxon(taxon)
				}
			}
		},
		methods: {
			selectTaxon(taxon) {
				this.$emit('onTaxonSelect', taxon)
			},
			isSelected(taxon) {
				if(this.selected) {
					return this.selected.id == taxon.id
				}
				return false
			}
		}
	}
</script>