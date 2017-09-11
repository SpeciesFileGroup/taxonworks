<template>
	<div v-show="list.length">
	    	<transition-group class="table-entrys-list" name="list-complete" tag="ul">
	    	<li v-for="item, index in list" :key="item.id" class="list-complete-item flex-separate middle">
			    <span><span v-for="show in display" v-html="item[show] + ' '"></span></span>
			    <div class="horizontal-left-content">
					<autocomplete
						url="/sources/autocomplete"
						min="3"
						param="term"
						event-send="sourceSelect"
						@getItem="test($event,item)"
						label="label_html"
						placeholder="Type for search..."
						:sendLabel="getCitation(item)"
						display="label">
					</autocomplete>
					<input :disabled="!getCitation(item)" placeholder="Pages" class="pages" type="text"/>
		    		<span type="button" class="circle-button btn-delete" @click="$emit('delete',item)">Remove</span>
		    	</div>
	    	</li>
	    	</transition-group>
    </div>
</template>
<script>

const ActionNames = require('../store/actions/actions').ActionNames;
const GetterNames = require('../store/getters/getters').GetterNames;
const autocomplete = require('../../../components/autocomplete.vue');

export default {
	components: {
		autocomplete
	},
	props: ['list', 'display'],
	name: 'list-entrys',
	methods: {
		getCitation: function(item) {
			console.log(item.hasOwnProperty('origin_citation') ? item.origin_citation.source.object_tag : undefined);
			return (item.hasOwnProperty('origin_citation') ? item.origin_citation.source.object_tag : undefined)
		},
		test(event,item) {
			let citation = {
				id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
				source_id: event.id
			}
			item['origin_citation_attributes'] = citation;
			console.log(item);
			this.$store.dispatch(ActionNames.UpdateClassification,item)
		}
	}
}
</script>

<style type="text/css" scoped>
.pages {
	width: 80px;
}
.pages:disabled {
	background-color: #F5F5F5;
}
.table-entrys-list {
  	padding: 0px;
  	position: relative;

    li {
		margin: 0px;
		padding: 6px;
		border-top: 1px solid #f5f5f5;
    }
}
.list-complete-item {
  transition: all 1s, opacity 0.2s;

}
.list-complete-enter, .list-complete-leave-to
{
  opacity: 0;
  font-size: 0px;
  border:none;
  transform: scale(0.0);
}
.list-complete-leave-active {
	width: 100%;
	position: absolute;
}
</style>