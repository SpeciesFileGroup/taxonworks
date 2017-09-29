<template>
    <div class="qualitative-descriptor">
        <summary-view v-bind:descriptor="descriptor">
            <ul>
                <li v-for="characterState in descriptor.characterStates">
                    <label>
                        <input
                            type="checkbox"
                            :checked="isStateChecked(characterState.id)"
                            @change="updateStateChecked(characterState.id, $event)" />

                        {{ characterState.label }}: {{ characterState.name }}
                    </label>
                </li>
            </ul>
        </summary-view>

        <zoomed-view v-bind:descriptor="descriptor">
            <h2 class="qualitative-descriptor__descriptor-title">{{ descriptor.title }}</h2>
            <div class="qualitative-descriptor__descriptor-details">
                <descriptor-details v-bind:descriptor="descriptor"></descriptor-details>
            </div>
            <div class="qualitative-descriptor__character-state-list">
                <div
                    class="qualitative-descriptor__character-state"
                    v-for="characterState in descriptor.characterStates">

                    <div class="qualitative-descriptor__character-state-details">
                        <label>
                            <input
                                type="checkbox"
                                :checked="isStateChecked(characterState.id)"
                                @change="updateStateChecked(characterState.id, $event)" />

                            {{ characterState.label }}: {{ characterState.name }}
                        </label>
                    </div>
                    <div class="qualitative-descriptor__observation-details">
                        <observation-details v-bind:observation="getCharacterStateObservation(characterState.id)"></observation-details>
                    </div>
                </div>
            </div>
        </zoomed-view>
    </div>
</template>

<style src="./QualitativeDescriptor.styl" lang="stylus"></style>

<script>
    import { ActionNames } from '../../store/actions/actions';
    import { MutationNames } from '../../store/mutations/mutations';
    import { GetterNames } from '../../store/getters/getters';

    import summaryView from '../SummaryView/SummaryView.vue';
    import zoomedView from '../ZoomedView/ZoomedView.vue';

    import observationDetails from '../ObservationDetails/ObservationDetails.vue';
    import descriptorDetails from '../DescriptorDetails/DescriptorDetails.vue';

    export default {
        name: 'qualitative-descriptor',
        props: ['descriptor'],
        created: function() {
            const descriptorId = this.$props.descriptor.id;
            const otuId = this.$store.state.taxonId;
            //this.$store.dispatch(ActionNames.RequestDescriptorDepictions, descriptorId);
            //this.$store.dispatch(ActionNames.RequestDescriptorNotes, descriptorId);
            this.$store.dispatch(ActionNames.RequestObservations, { descriptorId, otuId })
                .then(_ => this.$store.getters[GetterNames.GetObservationsFor](descriptorId))
                .then(observations => {
                    this.observations = observations;
                    this.observations.forEach(observation => {
                        if (observation.id) {
//                            this.$store.dispatch(ActionNames.RequestObservationCitations, observation.id);
//                            this.$store.dispatch(ActionNames.RequestObservationConfidences, observation.id);
//                            this.$store.dispatch(ActionNames.RequestObservationDepictions, observation.id);
//                            this.$store.dispatch(ActionNames.RequestObservationNotes, observation.id);
                        }
                    });
                });
        },
        data: function() {
            return {
                observations: []
            };
        },
        methods: {
            isStateChecked(characterStateId) {
                return this.$store.getters[GetterNames.GetCharacterStateChecked]({
                    descriptorId: this.$props.descriptor.id,
                    characterStateId
                });
            },
            getCharacterStateObservation(characterStateId) {
                const observations = this.$store.getters[GetterNames.GetObservationsFor](this.$props.descriptor.id);
                return observations.find(o => o.characterStateId === characterStateId);
            },
            updateStateChecked(characterStateId, event) {
                this.$store.commit(MutationNames.SetCharacterStateChecked, {
                    descriptorId: this.$props.descriptor.id,
                    characterStateId,
                    isChecked: event.target.checked
                });
            }
        },
        components: {
            summaryView,
            zoomedView,
            observationDetails,
            descriptorDetails
        }
    };
</script>