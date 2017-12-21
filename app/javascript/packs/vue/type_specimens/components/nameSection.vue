<template>
  <div class="panel type-specimen-box">
    <div class="header flex-separate middle">
        <h3>Taxon name</h3>
        <expand v-model="displayBody"></expand>
    </div>
    <div class="body" v-if="displayBody">
      <div class="field">
        <label>Protonym</label>
        <autocomplete
          url="/taxon_names/autocomplete"
          param="term"
          label="label_html"
          display="label"
          @getItem="protonymId = $event.id"
          min="2"
          :add-params="{
            'type[]': 'Protonym',
            valid: true
          }">
        </autocomplete>
      </div>
    </div>
  </div>
</template>

<script>

  import expand from './expand.vue';
  import autocomplete from '../../components/autocomplete.vue';
  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  
  export default {
    components: {
      autocomplete,
      expand
    },
    computed: {
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
        displayBody: true
      }
    }
  }
</script>