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
		<ul>
			<draggable v-model="roles_attributes">
				<li v-for="role in roles_attributes" v-html="getFullName(role.person.first_name, role.person.last_name)"></li>
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
				roles_attributes: this.value,
				role_types: undefined
			}
		},
		mounted: function() {
			this.loadPeople();
			this.$on('role_picker', function(item) {
				this.roles_attributes = [];
				this.roles_attributes.push(this.addPerson(item));
				this.$emit('input', this.roles_attributes);
			});
		},
		methods: {
			loadPeople: function() {
				this.$http.get('/people/role_types.json').then( response => {
					this.role_types = response.body;
				})
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
			createNewPerson: function(label) {
				return {
					first_name: this.getFirstName(label),
					last_name: this.getLastName(label)
				}
			},
			addPerson: function(item) {
				return {
					person: {
						type: this.roleSelected,
						person_id: item.object_id,
						first_name: this.getFirstName(item.label),
						last_name: this.getLastName(item.label)
					},
					position: this.roles_attributes.length
				}
			}
		}
	}
</script>
