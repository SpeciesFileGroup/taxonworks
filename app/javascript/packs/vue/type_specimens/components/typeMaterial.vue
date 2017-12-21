<template>
  <div class="panel type-specimen-box">
    <spinner :show-spinner="false" :show-legend="false" v-if="!protonymId"></spinner>
    <div class="header flex-separate middle">
        <h3>Material</h3>
        <expand v-model="displayBody"></expand>
    </div>
    <div class="body" v-if="displayBody">

      <div class="switch-radio field">
        <template v-for="item, index in tabOptions">
          <input 
            v-model="view"
            :value="item"
            :id="`switch-picker-${index}`" 
            name="switch-picker-options"
            type="radio"
            class="normal-input button-active" 
          />
          <label :for="`switch-picker-${index}`" class="capitalize">{{ item }}</label>
        </template>
      </div>

      <collection-object v-if="view == 'new'"></collection-object>

      <template v-if="view == 'material'">

        <div class="field">
          <label>Material</label>
          <autocomplete
            url="/collection_objects/autocomplete"
            param="term"
            label="label_html"
            @getItem="protonymId = $event.id"
            display="label"
            min="2">
          </autocomplete>
        </div>

        <div class="field">
          <button type="button" class="normal-input button button-submit">Create</button>
        </div>
      </template>

    </div>
  </div>
</template>

<script>

  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';

  import autocomplete from '../../components/autocomplete.vue';
  import spinner from '../../components/spinner.vue';
  import expand from './expand.vue';
  import collectionObject from './collectionObject.vue';
  
  export default {
    components: {
      collectionObject,
      autocomplete,
      expand,
      spinner
    },
    computed: {
      protonymId: {
        get() {
          return this.$store.getters[GetterNames.GetProtonymId];
        },
        set(value) {
          this.$store.commit(MutationNames.SetProtonymId, value);
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
      getTypeMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      }
    },
    data: function() {
      return {
        view: 'new',
        tabOptions: ['material', 'new'],
        displayBody: true,
        roles_attribute: [],
      }
    }
  }
</script>