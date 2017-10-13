<template>
	<transition-group class="table-entrys-list" name="list-complete" tag="ul">
	    	<li v-for="item in list" :key="item.id" class="list-complete-item flex-separate middle">
			    <span class="list-item" v-html="item[label]"></span>
			    <div class="list-controls">		
		    		<span type="button" class="circle-button btn-delete" @click="$emit('delete', item)">Remove</span>
		    	</div>
	    	</li>
	</transition-group>
</template>
<script>
	export default {
		props: {
			list: {
				default: []
			},
			label: {
				type: String,
				required: true,
			}
		}
	}
</script>
<style lang="scss" scoped>

	.list-controls {
	 	display: flex;
	 	align-items:center;
	 	flex-direction:row;
	 	justify-content: flex-end;
	}

	.list-item {
		a {
			padding-left: 4px;
			padding-right: 4px;
		}
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