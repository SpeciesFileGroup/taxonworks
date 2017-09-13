<template>
	<div v-show="list.length">
	    	<transition-group class="table-entrys-list" name="list-complete" tag="ul">
	    	<li v-for="item, index in list" :key="item.id" class="list-complete-item flex-separate middle">
			    <span><span v-for="show in display" v-html="item[show] + ' '"></span></span>
			    <div class="list-controls">
			    	<span v-if="getCitation(item)" v-html="getCitation(item)"></span>
			    	<div class="list-controls" v-else>
						<autocomplete 
							url="/sources/autocomplete"
							min="3"
							param="term"
							event-send="sourceSelect"
							@getItem="sendCitation($event.id,item)"
							label="label_html"
							placeholder="Type for search..."
							:sendLabel="getCitation(item)"
							display="label">
						</autocomplete>
						<default-element label="source" type="Source" section="Sources" @getId="sendCitation($event,item)"></default-element>
					</div>
					<input ref="inputPages" :disabled="!getCitation(item)" @input="autoSave(index, item)" placeholder="Pages" class="pages" type="text"/>
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
const defaultElement = require('../../../components/getDefaultPin.vue');

export default {
	components: {
		autocomplete,
		defaultElement
	},
	props: ['list', 'display'],
	name: 'list-entrys',
	data: function() {
		return {
			autosave: [],
		}
	},
	methods: {
		getCitation: function(item) {
			return (item.hasOwnProperty('origin_citation') ? item.origin_citation.source.object_tag : undefined)
		},
		sendCitation(sourceId,item) {
			let citation = {
				id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
				source_id: sourceId
			}

			let copy = Object.assign({}, item)
			copy['origin_citation_attributes'] = citation;

			this.$emit('addCitation', copy);
		},
		setPages(index, item) {
			let input = this.$refs.inputPages[index].value;
			let citation = {
				id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
				pages: input
			}
			let copy = Object.assign({}, item)
				copy['origin_citation_attributes'] = citation;

			this.$emit('addCitation', copy);
			console.log(copy);
		},
        resetAutoSave: function(index) {
          clearTimeout(this.autosave[index]);
          this.autosave[index] = null          
        },  
        autoSave: function(index, item) {
          var that = this;
          if(this.autosave[index]) {
            this.resetAutoSave(index);
          }   
          this.autosave[index] = setTimeout(function() {    
            that.setPages(index, item);  
          }, 3000);
        },
	}
}
</script>

<style type="text/css" scoped>
.pages {
	margin-left: 8px;
	width: 70px;
}
.list-controls {
 	display: flex;
 	align-items:center;
 	flex-direction:row;
 	justify-content: flex-end;
	width: 550px;
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