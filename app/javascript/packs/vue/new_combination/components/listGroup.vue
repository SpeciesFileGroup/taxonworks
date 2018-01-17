<template>
	<div class="new-combination-rank-list">
		<div class="header">
			<h3 class="flex-separate">
				<ul class="breadcrumb_list">
					<li class="capitalize">{{ rankName }} </li>
					<li class="breadcrumb_item" v-if="selected">
						<b><span v-html="selected.original_combination"></span></b>
					</li>
				</ul>
				<expand v-if="list.length > 1" v-model="expanded"></expand>
			</h3>
		</div>
		<ul v-if="expanded">
			<li class="no_bullets" v-for="taxon in inOrder(list)">
				<label class="middle">
					<input type="radio" v-model="rankChoose" :value="taxon"/>
					<span v-html="taxon.original_combination"></span>
				</label>
			</li>
		</ul>
	</div>
</template>
<script>

	import expand from '../../components/expand.vue';

	export default {
		components: {
			expand
		},
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
		data: function() {
			return {
				expanded: true,
			}
		},
		watch: {
			selected: {
				handler(newVal) {
					if(newVal) {
						this.expanded = false
					}
					else {
						this.expanded = true
					}
				},
				immediate: true
			}
		},
		methods: {
			inOrder(list) {
				let newOrder = list.slice(0);
					newOrder.sort((a,b) => {
						if (a.original_combination < b.original_combination)
							return -1;
						if (a.original_combination > b.original_combination)
							return 1;
						return 0;						
					});
				return newOrder;
			},
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
<style lang="scss">
	.new-combination-rank-list {
		.header {
			padding: 1em;
			padding-left: 1.5em;
			border-bottom: 1px solid #f5f5f5;
			border-top: 1px solid #f5f5f5;
			h3 {
				font-weight: 300;
			}
		}
	}
</style>