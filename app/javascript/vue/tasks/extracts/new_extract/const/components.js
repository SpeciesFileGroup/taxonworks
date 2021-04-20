import OriginComponent from '../components/Origin'
import MadeComponent from '../components/Made'
import Identifier from '../components/Identifier'
import CustomAttributes from '../components/CustomAttributes'
import Protocols from '../components/Protocols'
import Repository from '../components/Repository'
import ByComponent from '../components/Role'

const VueComponent = {
  By: ByComponent,
  Made: MadeComponent,
  Protocols: Protocols,
  Identifier: Identifier,
  Origin: OriginComponent,
  Repository: Repository,
  CustomAttributes: CustomAttributes
}

export {
  VueComponent
}
