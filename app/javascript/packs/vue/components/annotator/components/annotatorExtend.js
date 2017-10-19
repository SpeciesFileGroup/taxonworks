const vueAnnotator = {
	props: {
		type: {
			type: String,
			required: true
		},
		url: {
			type: String,
			required: true
		},
		globalId: {
			type: String,
			required: true
		}
	},
	data: function() {
		return {
			list: [],
		}
	},
	mounted: function() {
		var that = this;
		this.getList(`${this.url}/${this.type}.json`).then(response => {
			that.list = response.body;
		})
	},
	watch: {
		list: {
			handler: function() {
				this.updateCount();
			}
		}
	},
	methods: {
		removeFromList(id) {
			let position = this.list.findIndex(function(element) {
				return element.id == id;
			});

			if(position > -1) {
				this.list.splice(position, 1);
			}
		},
		removeItem(item) {
			this.destroy(`/${this.type}/${item.id}`, item).then(response => {
				this.removeFromList(item.id);
			});
		},
		updateCount() {
			this.$emit('updateCount', this.list.length);
		}
	}
}

export default vueAnnotator