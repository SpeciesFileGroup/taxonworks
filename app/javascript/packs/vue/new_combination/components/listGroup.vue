<template>
	<div class="new-combination-rank-list">
		<div class="header">
			<h3 class="flex-separate">
				<span class="capitalize">{{ rankName }}</span>
			</h3>
		</div>
		<template v-if="list.length">
			<ul v-if="expanded">
				<li class="no_bullets" v-for="taxon in inOrder(list)">
					<label class="middle new-combination-rank-list-label"
						@mousedown="rankChoose = taxon" >
						<input 
							ref="rankRadio"
							:name="`new-combination-rank-list-${rankName}`" 
							@keyup.enter="rankChoose = taxon"
							class="new-combination-rank-list-input" type="radio" 
							:checked="checkRankSelected(taxon)" :value="taxon">
						<span 
							class="new-combination-rank-list-taxon-name" 
							v-html="taxon.original_combination">
						</span>
					</label>
				</li>
			</ul>
			<div class="maxheight content middle item" v-else>
				<h3 v-if="selected">
					<b><span v-html="selected.original_combination"></span></b>
				</h3>
			</div>
		</template>
		<template v-else>
			<div class="maxheight content middle item">
				<h3>{{ parseString }} not found</h3>
			</div>
		</template>
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
			parseString: {
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
					this.$emit('rankPicked', this.rankName);
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
			list: {
				handler(newVal) {
					if(newVal.length == 1) {
						this.rankChoose = newVal[0]
						this.expanded = false
					}
				},
				immediate: true
			}
		},
		methods: {
			checkRankSelected(taxon) {
				if(this.rankChoose && taxon.id == this.rankChoose.id) {
					return true
				}
				return false
			},
			expandList: function() {
				if(this.list.length > 1)
					this.expanded = true;
			},
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
				this.expanded = false;
				this.$emit('onTaxonSelect', taxon)
			},
			setFocus() {
				if(this.rankRadio.length > 1) {
					if(this.selected) {
						this.$refs.rankRadio[this.list.findIndex((taxon) => {
							return taxon == this.selected
						})].$el.focus();
					}
					else {
						this.$refs.rankRadio[0].$el.focus();
					}
				}
				else {
					this.$refs.rankRadio.$el.focus();
				}
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
		transition: all 0.5 ease;
		display: flex;
		flex-direction: column;
		.header {
			padding: 1em;
			padding-left: 1.5em;
			border-bottom: 1px solid #f5f5f5;
			h3 {
				font-weight: 300;
			}
		}
		.maxheight {
			flex:1
		}
		.new-combination-rank-list-label {
			cursor: pointer;
			transition: all 0.5 ease;
		}
		.new-combination-rank-list-label:hover .new-combination-rank-list-taxon-name {
			font-weight: bold;
		}
		.new-combination-rank-list-input:focus + .new-combination-rank-list-taxon-name {
			font-weight: bold;
		}
	}
</style>