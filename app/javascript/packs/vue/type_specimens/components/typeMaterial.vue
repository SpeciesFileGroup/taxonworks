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
      <div class="flex-separate">
        <div>
          <collection-object v-if="view == 'new'"></collection-object>

          <template v-if="view == 'material'">

            <div class="field">
              <label>Material</label>
              <autocomplete
                class="types_field"
                url="/collection_objects/autocomplete"
                param="term"
                label="label_html"
                :sendLabel="getOwnPropertyNested(typeMaterial, 'collection_object', 'object_tag')"
                @getItem="biologicalId = $event.id"
                display="label"
                min="2">
              </autocomplete>
            </div>
            <div class="field">
              <button v-if="typeMaterial.id" @click="updateTypeMaterial" type="button" class="normal-input button button-submit">Update</button>
              <button v-else @click="createTypeMaterial" :disabled="!biologicalId" type="button" class="normal-input button button-submit">Create</button>
            </div>
          </template>
        </div>
        <div class="field" v-if="protonymId">
          <label>Depiction</label>
          <depictions-section></depictions-section>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  import ActionNames from '../store/actions/actionNames';

  import autocomplete from '../../components/autocomplete.vue';
  import spinner from '../../components/spinner.vue';
  import expand from './expand.vue';
  import collectionObject from './collectionObject.vue';
  import depictionsSection from './depictions.vue';
  
  export default {
    components: {
      depictionsSection,
      collectionObject,
      autocomplete,
      expand,
      spinner
    },
    computed: {
      typeMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      },
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
      biologicalId: {
        get() {
          return this.$store.getters[GetterNames.GetBiologicalId]
        },
        set(value) {
          this.$store.commit(MutationNames.SetBiologicalId, value)
        }
      },
      view: {
        get() {
          return this.$store.getters[GetterNames.GetSettings].materialTab
        },
        set(value) {
          this.$store.commit(MutationNames.SetMaterialTab, value)
        }
      }
    },
    data: function() {
      return {
        tabOptions: ['material', 'new'],
        displayBody: true,
        roles_attribute: [],
      }
    },
    watch: {
      typeMaterial(newVal) {
        if(newVal.id) {
          this.view = 'material';
        }
      }
    },
    methods: {
      createTypeMaterial() {
        this.$store.dispatch(ActionNames.CreateTypeMaterial);
      },
      updateTypeMaterial() {
        let type_material = this.$store.getters[GetterNames.GetTypeMaterial];
        this.$store.dispatch(ActionNames.UpdateTypeSpecimen, { type_material: type_material });
      },
      getOwnPropertyNested(obj) {
        var args = Array.prototype.slice.call(arguments, 1);

        for (var i = 0; i < args.length; i++) {
          if (!obj || !obj.hasOwnProperty(args[i])) {
            return undefined;
          }
          obj = obj[args[i]];
        }
        return obj;
      }
    }
  }
</script>