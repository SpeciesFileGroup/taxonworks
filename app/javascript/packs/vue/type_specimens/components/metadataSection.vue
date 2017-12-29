<template>
  <div class="panel type-specimen-box">
    <spinner :show-spinner="false" :show-legend="false" v-if="!protonymId"></spinner>
    <div class="header flex-separate middle">
        <h3>Metadata</h3>
        <expand v-model="displayBody"></expand>
    </div>
    <div class="body" v-if="displayBody">
        <div class="field">
          <label>Type designator</label>
          <role-picker v-model="roles" class="types_field">    
          </role-picker>
        </div>
        <div class="field">
          <label>Type</label>
          <select v-model="type" class="normal-input">
            <option class="capitalize" :value="item" v-for="item in types">{{ item }}</option>
          </select>
        </div>
    </div>
  </div>
</template>

<script>

  import expand from './expand.vue';
  import autocomplete from '../../components/autocomplete.vue';
  import spinner from '../../components/spinner.vue';
  import rolePicker from '../../components/role_picker.vue';
  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  
  export default {
    components: {
      autocomplete,
      rolePicker,
      spinner,
      expand
    },
    computed: {
      roles: {
        get() {
          return [];
        },
        set(value) {
          this.$store.commit(MutationNames.SetRoles, value);
        }
      },
      type: {
        get() {
          return this.$store.getters[GetterNames.GetType];
        },
        set(value) {
          this.$store.commit(MutationNames.SetType, value);
        }
      },
      protonymId: {
        get() {
          return this.$store.getters[GetterNames.GetProtonymId];
        },
        set(value) {
          this.$store.commit(MutationNames.SetProtonymId, value);
        }
      }
    },
    data: function() {
      return {
        displayBody: true,
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