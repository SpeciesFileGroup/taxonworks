<template>
	<div class="basic-information panel">
		<a name="etymology" class="anchor"></a>
		<div class="header flex-separate middle">
			<h3>Etymology</h3>
			<expand @changed="expanded = !expanded" :expanded="expanded"></expand>
		</div>
		<div class="body" v-show="expanded">
			<markdown-editor class="edit-content" v-model="etymology" :configs="config" ref="etymologyText"></markdown-editor>
		</div>
	</div>
</template>
<script>

	const GetterNames = require('../store/getters/getters').GetterNames
	const MutationNames = require('../store/mutations/mutations').MutationNames
    const markdownEditor = require('../../../components/markdown-editor.vue');
	const expand = require('./expand.vue');

	export default {
		components: {
			markdownEditor,
			expand
		},
		computed: {
			etymology: {
				get() {
					return this.$store.getters[GetterNames.GetEtymology]
				},
				set(text) {
					this.$store.commit(MutationNames.SetEtymology, text);
					this.$store.commit(MutationNames.UpdateLastChange)
				}
			}
		},
		data: function() {
			return {
				expanded: true,
				config: {
					status: false,
		            toolbar: ["bold", "italic", "code", "heading", "|", "quote", "unordered-list", "ordered-list", "|", "link", "table", "preview"],
		            spellChecker: false,
				},
			}
		}
	}
</script>