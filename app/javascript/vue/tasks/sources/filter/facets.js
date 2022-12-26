import TitleComponent from './components/filters/title'
import AuthorsComponent from './components/filters/authors'
import DateComponent from './components/filters/date'
import TagsComponent from './components/filters/tags'
import IdentifierComponent from './components/filters/identifiers'
import CitationTypesComponent from './components/filters/citationTypes'
import SerialsComponent from './components/filters/serials'
import WithComponent from './components/filters/with'
import TypeComponent from './components/filters/type'
import TopicsComponent from './components/filters/topics'
import UsersComponent from 'components/Filter/Facets/shared/FacetUsers.vue'
import SomeValueComponent from './components/filters/SomeValue/SomeValue'
import TaxonNameComponent from './components/filters/TaxonName'
import FacetMatchIdentifiers from 'components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import FacetBibtexType from './components/filters/FacetBibtexType.vue'

export const facets = [
  {
    component: TitleComponent
  },
  {
    component: AuthorsComponent
  },
  {
    component: DateComponent
  },
  {
    component: TagsComponent
  },
  {
    component: IdentifierComponent
  },
  {
    component: CitationTypesComponent
  },
  {
    component: SerialsComponent
  },
  {
    component: TypeComponent
  },
  {
    component: TopicsComponent
  },
  {
    component: UsersComponent
  },
  {
    component: SomeValueComponent
  },
  {
    component: TaxonNameComponent
  },
  {
    component: FacetMatchIdentifiers
  },
  {
    component: FacetBibtexType
  },
  {
    component: WithComponent
  }
]
