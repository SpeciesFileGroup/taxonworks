import getObservationFromArgs from '../helpers/getObservationFromArgs';

export default function(state, args) {
    getObservationFromArgs(state, args).id = args.observationId;
};