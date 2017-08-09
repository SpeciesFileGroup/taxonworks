<template>
	<div>
		<autocomplete
			url="/people/lookup_person"
			label="label"
		    min="2"
		    eventSend="role_picker"
		    placeholder="Family name, given name"
		    param="term">
		</autocomplete>
		<select class="normal-input" v-if="!type">
			<option v-for="role, key in role_types">{{ role }}</option>
		</select>
		<ul class="table-entrys-list">
			<draggable v-model="roles_attributes" @end="onSortable">
				<li class="flex-separate middle" v-for="role, index in roles_attributes" v-if="!role.hasOwnProperty('_destroy')">
					<span v-html="getFullName(role.first_name, role.last_name)"></span>
					<span class="circle-button btn-delete" @click="removePerson(index)"></span>
				</li>
			</draggable>
		</ul>
	</div>
</template>

<script>

	const autocomplete = require('./autocomplete.vue');
  	const draggable = require('vuedraggable');

	export default {
		components: {
			autocomplete,
			draggable
		},
		props: {
			type: {
				type: String,
				default: undefined
			},
			value: undefined
		},
		data: function() {
			return {
				roleSelected: this.type,
				roles_attributes: this.sortPosition(this.processedList(this.value)),
				role_types: undefined
			}
		},
		mounted: function() {
			this.loadRoles();
			this.$on('role_picker', function(item) {
				this.roles_attributes.push(this.addPerson(item));
				this.$emit('input', this.roles_attributes);
			});
		},
		watch: {
			value: function(newVal) {
				this.roles_attributes = this.sortPosition(this.processedList(this.value))
			}
		},
		methods: {
			loadRoles: function() {
				this.$http.get('/people/role_types.json').then( response => {
					this.role_types = response.body;
				})
			},
			removePerson: function(index) {
				this.$set(this.roles_attributes[index], '_destroy', true);
				this.$emit('input', this.roles_attributes);
			},
			sortPosition: function(list) {
				list.sort(function(a, b){
					if(a.position > b.position)
				    	return 1
				    return -1;
				});
				return list;
			},
			processedList: function(list) {
				if(list == undefined) return [];
				let tmp = [];

				list.forEach(function(element, index) {
					if(element.hasOwnProperty('person')) {
						let item = {
							id: element.id,
							first_name: element.person.first_name,
							last_name: element.person.last_name,
							position: element.position
						}
						tmp.push(item);
					}
					else {
						let item = {
							type: element.type,
							person_id: element.person_id,
							first_name: element.first_name,
							last_name: element.last_name,
							position: element.position
						}
						tmp.push(item);
					}
				});
				return tmp;
			},
			updateIndex: function() {
				var that = this;
				this.roles_attributes.forEach(function(element, index) {
					that.roles_attributes[index].position = (index+1);
				});
			},
			onSortable: function() {
				this.updateIndex();
				this.$emit('input', this.roles_attributes);
			},
			findName: function(string, position) {
				var delimiter;
				if (string.indexOf(",") > 1) {
					delimiter = ","
				}
				if (string.indexOf(", ") > 1) {
					delimiter = ", "
				}
				if (string.indexOf(" ") > 1 && delimiter != ", ") {
					delimiter = " "
				}
				return string.split(delimiter, 2)[position]
			},
			getFirstName: function (string) {
				if ((string.indexOf(",") > 1) || (string.indexOf(" ") > 1)) {
					return this.findName(string, 1);
				} else {
					return null;
				}
			},
			getLastName: function (string) {
				if ((string.indexOf(",") > 1) || (string.indexOf(" ") > 1)) {
					return this.findName(string, 0);
				} 
				else {
					return string
				}
			},
			getFullName: function (first_name, last_name) {
				var separator = "";
				if (!!last_name && !!first_name) {
					separator = ", ";
				}
				return (last_name + separator + first_name);
			},
			addPerson: function(item) {
				return {
					type: this.roleSelected,
					person_id: item.object_id,
					first_name: this.getFirstName(item.label),
					last_name: this.getLastName(item.label),
					position: (this.roles_attributes.length+1)
				}
			}
		}
	}
</script>
