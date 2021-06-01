import { makeInitialState } from '../store'
import MatrixRowCoderRequest from '../../request/MatrixRowCoderRequest'

export default function(state) {
  Object.assign(state, makeInitialState(new MatrixRowCoderRequest()))
}