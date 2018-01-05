<template>
  <div>
    <div class="field types_field">
      <label>Buffered collecting event</label>
      <textarea rows="5" v-model="bufferedEvent"></textarea>
    </div>
    <div class="field types_field">
      <label>Buffered determinations</label>
      <textarea rows="5" v-model="bufferedDeterminations"></textarea>
    </div>
    <div class="field types_field">
      <label>Buffered other labels</label>
      <textarea rows="5" v-model="bufferedLabels"></textarea>
    </div>
    <div class="field">
      <label>Total</label>
      <input type="number" v-model="total"/>
    </div>
    <div class="field">
      <label>Preparation type</label>
      <select v-model="preparationId" class="normal-input">
        <option v-for="item in types" :value="item.id">{{ item.name }}</option>
      </select>
    </div>
    <div class="field">
      <label>Repository</label>
      <autocomplete
        class="types_field"
        url="/repositories/autocomplete"
        param="term"
        label="label_html"
        placeholder="Select a repository"
        @getItem="repositoryId = $event.id"
        display="label"
        min="2">
      </autocomplete>
    </div>
    <div class="field">
      <label>Collection event</label>
      <autocomplete
        class="types_field"
        url="/collecting_events/autocomplete"
        param="term"
        label="label_html"
        placeholder="Select a collection event"
        @getItem="eventId = $event.id"
        display="label"
        min="2">
      </autocomplete>
    </div>

    <div class="field">
      <button @click="updateTypeMaterial" v-if="typeMaterial.id" type="button" class="button normal-input button-submit">Update</button>
      <button @click="createTypeMaterial" v-else :disabled="total < 1" type="button" class="button normal-input button-submit">Create</button>
    </div>
  </div>
</template>

<script>
  
  import autocomplete from '../../components/autocomplete.vue';
  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  import { GetPreparationTypes } from '../request/resources';
  import ActionNames from '../store/actions/actionNames';

  export default {
    components: {
      autocomplete
    },
    computed: {
      typeMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      },
      repositoryId: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectRepositoryId]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectRepositoryId, value);
        }
      },
      bufferedDeterminations: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectBufferedDeterminations]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectBufferedDeterminations, value);
        }
      },
      bufferedEvent: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectBufferedEvent]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectBufferedEvent, value);
        }
      },
      bufferedLabels: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectBufferedLabels]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectBufferedLabels, value);
        }
      },
      eventId: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectEventId]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectEventId, value);
        }
      },
      preparationId: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectPreparationId]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectPreparationId, value);
        }
      },
      total: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectTotal]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectTotal, value);
        }
      }
    },
    data: function() {
      return {
        types: []
      }
    },
    mounted: function() {
      var that = this;
      GetPreparationTypes().then(response => {
        that.types = response;
      })
    },
    methods: {
      getTypeWithCollectionObject() {
        let type_material = this.$store.getters[GetterNames.GetTypeMaterial];

        type_material.biological_object_id = undefined;
        type_material.material_attributes = this.$store.getters[GetterNames.GetCollectionObject];

        return type_material
      },
      createTypeMaterial() {
        this.$store.dispatch(ActionNames.CreateTypeMaterial);
      },
      updateTypeMaterial() {
        this.$store.dispatch(ActionNames.UpdateTypeSpecimen, { type_material: this.getTypeWithCollectionObject() });
      }
    }
  }
</script>