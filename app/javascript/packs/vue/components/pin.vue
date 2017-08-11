<template>
	<div v-if="!pin" class="pin-button" @click="createPin()"></div>
	<div v-else class="unpin-button" @click="deletePin()"></div>
</template>

<script>
	export default {
		props: {
			pinObject: {
				type: Object,
				default: undefined
			},
			objectId: {
				required: true
			},
			type: {
				type: String,
				required: true
			}
		},
		data: function() {
			return {
				pin: this.pinObject,
				id: this.objectId
			}
		},
		watch: {
			pinObject: function(newVal) {
				this.pin = newVal;
			},
			objectId: function(newVal) {
				this.id = newVal
			}
		},
		methods: {
			createPin: function() {
				let pinItem =  {
					pinboard_item: {
						pinned_object_id: this.id,
						pinned_object_type: this.type 
					}
				}
				this.$http.post('/pinboard_items', pinItem).then( response => {
					this.pin = response.body;
					TW.workbench.alert.create('Pinboard item was successfully created.', "notice");
				});
			},
			deletePin: function() {
				this.$http.delete(`/pinboard_items/${this.pin.id}`, { _destroy: true }).then(response => {
					this.pin = undefined;
					TW.workbench.alert.create('Pinboard item was successfully destroyed.', "notice");
				});
			}
		}
	}
</script>