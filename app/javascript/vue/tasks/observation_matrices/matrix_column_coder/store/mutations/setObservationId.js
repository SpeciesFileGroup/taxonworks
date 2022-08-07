import getObservationFromArgs from '../../helpers/getObservationFromArgs'

export default function (state, args) {
  getObservationFromArgs(state, args).id = args.observationId
  getObservationFromArgs(state, args).global_id = args.global_id
}
