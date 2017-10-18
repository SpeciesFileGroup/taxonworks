<template>
	<transition-group class="table-entrys-list" name="list-complete" tag="ul">
	    	<li v-for="item in list" :key="item.id" class="list-complete-item flex-separate middle">
			    <span class="list-item" v-html="displayName(item)"></span>
			    <div class="list-controls">
			    	<span v-if="edit" class="circle-button btn-edit" @click="$emit('edit', Object.assign({}, item))">Edit</span>
		    		<span class="circle-button btn-delete" @click="$emit('delete', item)">Remove</span>
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
				required: true,
			},
			edit: {
				type: Boolean,
				default: false,
			}
		},
		methods: {
			displayName(item) {
				if(typeof this.label == 'string') {
					return item[this.label];
				}
				else {
					let tmp = item;
					this.label.forEach(function(label) {
						tmp = tmp[label]
						console.log(tmp);
					});
					return tmp;
				}
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
		max-height: 300px;
		overflow-y: scroll;
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