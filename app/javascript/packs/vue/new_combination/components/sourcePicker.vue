<template>
	<div class="new-combination-citation">
		<h3>Citation</h3>
		<div class="flex-separate middle">
			<template v-if="title">
				<a
					:href="`/sources/${origin_citation.source.id}/edit`" 
					v-html="origin_citation.source.object_tag">
				</a>
				<div class="horizontal-left-content">
					<input type="text" @input="sendCitation" v-model="pages" placeholder="Pages" />
					<span class="circle-button btn-delete" @click="remove()"></span>
				</div>
			</template>

			<template v-else>
				<autocomplete	
					class="separate-right"
					url="/sources/autocomplete"
					min="3"
					param="term"
					event-send="sourceSelect"
					label="label_html"
					@getItem="setSource($event); sendCitation()"
					placeholder="Type for search..."
					display="label">
				</autocomplete>
				<input type="text" @input="sendCitation" v-model="pages" placeholder="Pages" />
			</template>
		</div>
	</div>
</template>
<script>

	import autocomplete from '../../components/autocomplete.vue';

	export default {
		components: {
			autocomplete
		},
		props: {
			citation: {
				default: undefined,
			}
		},
		data: function() {
			return {
				origin_citation: {},
				title: undefined,
				pages: undefined,
				sourceId: undefined
			}
		},
		watch: {
			citation: { 
				handler(newVal) {
					this.reset();
					this.origin_citation = newVal;
					if(newVal) {
						this.pages = this.origin_citation.pages;
						this.id = this.origin_citation.id
						this.title = this.origin_citation.source.object_tag
					}
				},
				immediate: true
			},
		},
		methods: {
			reset() {
				this.title = undefined,
				this.pages = undefined,
				this.sourceId = undefined
			},
			sendCitation() {
				this.$emit('select', {
					origin_citation_attributes: {
						id: (this.origin_citation ? this.origin_citation.id : undefined),
						source_id: this.sourceId,
						pages: this.pages
					}
				})
			},
			remove() {
				this.$emit('select', {
					origin_citation_attributes: {
						id: (this.origin_citation.hasOwnProperty('id') ? this.origin_citation.id : undefined),
						_destroy: true
					}
				})
				this.title = undefined;		
			},
			setSource(source) {
				let newSource = {
					source: {
						object_tag: source.label_html
					}
				}
				this.sourceId = source.id
			}
		}
	}

</script>
<style lang="scss">
	.new-combination-citation {
		.vue-autocomplete {
			width: 100% !important;
			.vue-autocomplete-input {
				width: 100% !important;
			}
		}
		h3 {
			font-weight: 300
		}
	}
</style>