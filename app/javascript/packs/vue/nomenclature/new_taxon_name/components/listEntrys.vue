<template>
	<div v-show="list.length">
	    	<transition-group class="table-entrys-list" name="list-complete" tag="ul">
	    	<li v-for="item, index in list" :key="item.id" class="list-complete-item flex-separate middle">
			    <span><span v-for="show in display" v-html="item[show] + ' '"></span></span>
		    	<span type="button" class="circle-button btn-delete" @click="$emit('delete',item)">Remove</span>
	    	</li>
	    	</transition-group>
    </div>
</template>
<script>

const ActionNames = require('../store/actions/actions').ActionNames;
const GetterNames = require('../store/getters/getters').GetterNames;

export default {
	props: ['list', 'display'],
	name: 'list-entrys',
}
</script>

<style type="text/css">
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