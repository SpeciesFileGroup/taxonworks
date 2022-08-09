import { makeInitialState } from '../store'
import MatrixRowCoderRequest from '../../request/MatrixRowCoderRequest'

export default state => {
  Object.assign(state, makeInitialState(new MatrixRowCoderRequest()), { units: state.units })
}
