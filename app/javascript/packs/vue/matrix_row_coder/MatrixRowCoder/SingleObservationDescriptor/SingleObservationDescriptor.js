import { ActionNames } from '../../store/actions/actions';
import { GetterNames } from '../../store/getters/getters';

import summaryView from '../SummaryView/SummaryView.vue';
import singleObservationZoomedView from '../ZoomedView/SingleObservationZoomedView/SingleObservationZoomedView.vue';

export default {
    created: function() {
        const descriptorId = this.$props.descriptor.id;
        const otuId = this.$store.state.taxonId;

        //this.$store.dispatch(ActionNames.RequestDescriptorDepictions, descriptorId);
        //this.$store.dispatch(ActionNames.RequestDescriptorNotes, descriptorId);
        this.$store.dispatch(ActionNames.RequestObservations, {descriptorId, otuId})
            .then(_ => {
                const observations = this.$store.getters[GetterNames.GetObservationsFor](descriptorId);
                if (observations.length > 1) {
                    throw 'This descriptor cannot have more than one observation!';
                } else if (observations.length === 1) {
                    const observation = observations[0];
                    this.observation = observation;

                    if (this.observation.id) {
                        //this.$store.dispatch(ActionNames.RequestObservationCitations, observation.id);
                        //this.$store.dispatch(ActionNames.RequestObservationConfidences, observation.id);
                        //this.$store.dispatch(ActionNames.RequestObservationDepictions, observation.id);
                        //this.$store.dispatch(ActionNames.RequestObservationNotes, observation.id);
                    }
                }
            });
    },
    data: function() {
        return {
            observation: null
        }
    },
    props: ['descriptor'],
    components: {
        summaryView,
        singleObservationZoomedView
    }
};