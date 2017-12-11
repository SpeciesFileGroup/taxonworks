<template>
  <div class="panel type-specimen-box">
    <div class="header flex-separate middle">
        <h3>Specimen/Collection Object</h3>
        <expand v-model="displayBody"></expand>
    </div>
    <div class="body" v-if="displayBody">
      <div class="field">
        <label>Type designator</label>
        <role-picker v-model="roles">    
        </role-picker>
      </div>
      <div class="field">
        <label>Protonym</label>
        <autocomplete
          url="/taxon_names/autocomplete"
          param="term"
          label="label_html"
          display="label"
          min="2"
          :add-params="{
            'type[]': 'Protonym',
            valid: true
          }">
        </autocomplete>
      </div>
      <div class="field">
        <label>Material</label>
        <autocomplete
          url="/collection_objects/autocomplete"
          param="term"
          label="label_html"
          display="label"
          min="2">
        </autocomplete>
      </div>
      <div class="field">
        <label>Type</label>
        <select v-model="type">
          <option class="capitalize" :value="item" v-for="item in types">{{ item }}</option>
        </select>
      </div>
    </div>
  </div>
</template>

<script>

  import rolePicker from '../../components/role_picker.vue';
  import autocomplete from '../../components/autocomplete.vue';
  import expand from './expand.vue';
  
  export default {
    components: {
      autocomplete,
      rolePicker,
      expand,
    },
    computed: {
      roles: {
        get() {
          return [];
        },
        set(value) {
          this.roles_attribute = value;
        }
      }
    },
    data: function() {
      return {
        displayBody: true,
        roles_attribute: [],
        type: 'holotype',
        types: ['epitype',
                'holotype', 
                'isosyntype', 
                'isosyntypes', 
                'isotype', 
                'isotypes', 
                'lectotype', 
                'neotype', 
                'paralectotype', 
                'paralectotypes', 
                'paratype', 
                'paratypes', 
                'syntype', 
                'syntypes']
      }
    }
  }
</script>