<template>
  <div class="panel type-specimen-box">
    <div class="header flex-separate middle">
        <h3>Taxon name</h3>
        <expand v-model="displayBody"></expand>
    </div>
    <div class="body" v-if="displayBody">
      <div class="field">
        <label>Species name</label>
        <autocomplete
          class="types_field"
          url="/taxon_names/autocomplete"
          param="term"
          label="label_html"
          display="label"
          @getItem="setTypeSpecimen($event.id)"
          min="2"
          :add-params="{
            'type[]': 'Protonym',
            'nomenclature_group[]': 'SpeciesGroup',
            valid: true
          }">
        </autocomplete>
      </div>
      <display-list :list="typesMaterial" :annotator="true" @delete="removeTypeSpecimen" label="object_tag"></display-list>
    </div>
  </div>
</template>

<script>

  import expand from './expand.vue';
  import autocomplete from '../../components/autocomplete.vue';
  import displayList from '../../components/displayList.vue';

  import { DestroyTypeMaterial } from '../request/resources';
  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  import ActionNames from '../store/actions/actionNames';
  
  export default {
    components: {
      displayList,
      autocomplete,
      expand
    },
    computed: {
      typesMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterials];
      }
    },
    data: function() {
      return {
        displayBody: true
      }
    },
    methods: {
      setTypeSpecimen(id) {
        this.$store.dispatch(ActionNames.LoadTaxonName, id).then(() => {
          this.$store.dispatch(ActionNames.LoadTypeMaterials, id)
        })
      },
      removeTypeSpecimen(item) {
        this.$store.dispatch(ActionNames.RemoveTypeSpecimen, item.id);
      }
    }
  }
</script>