import PanelAuthor from '../components/Panel/PanelAuthor.vue'
import PanelCopyrightHolder from '../components/Panel/PanelCopyrightHolder.vue'
import PanelEditor from '../components/Panel/PanelEditor.vue'
import PanelLicenses from '../components/Panel/PanelLicenses.vue'
import PanelOwner from '../components/Panel/PanelOwner.vue'
import PanelSource from '../components/Panel/PanelSource.vue'
import PanelTags from '../components/Panel/PanelTags.vue'
import PanelScalebar from '../components/Panel/PanelScalebar.vue'
import PanelDepicSome from '../components/Panel/PanelDepicSome.vue'
import PanelDepiction from '../components/Panel/PanelDepiction.vue'

export const PANEL_NAME = {
  PanelAuthor: 'PanelAuthor',
  PanelEditor: 'PanelEditor',
  PanelOwner: 'PanelOwner',
  PanelLicenses: 'PanelLicenses',
  PanelSource: 'PanelSource',
  PanelCopyrightHolder: 'PanelCopyrightHolder',
  PanelScalebar: 'PanelScalebar',
  PanelDepicSome: 'PanelDepicSome',
  PanelDepiction: 'PanelDepiction',
  PanelTags: 'PanelTags'
}

export const PANEL_COMPONENTS = {
  [PANEL_NAME.PanelAuthor]: PanelAuthor,
  [PANEL_NAME.PanelCopyrightHolder]: PanelCopyrightHolder,
  [PANEL_NAME.PanelEditor]: PanelEditor,
  [PANEL_NAME.PanelLicenses]: PanelLicenses,
  [PANEL_NAME.PanelOwner]: PanelOwner,
  [PANEL_NAME.PanelSource]: PanelSource,
  [PANEL_NAME.PanelScalebar]: PanelScalebar,
  [PANEL_NAME.PanelDepicSome]: PanelDepicSome,
  [PANEL_NAME.PanelDepiction]: PanelDepiction,
  [PANEL_NAME.PanelTags]: PanelTags
}

/* 
      <PanelAuthor />
      <PanelEditor />
      <PanelOwner />
      <PanelLicenses />
      <PanelSource />
      <PanelCopyrightHolder />
      <pixels-unit />
      <depic-some />
      <depiction-component />
      <PanelTag />
       */
