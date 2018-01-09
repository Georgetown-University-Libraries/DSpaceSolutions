# DSpaceSolutions
Repository to illustrate solutions to common DSpace Issues applied to the [DSpace Code Base](https://github.com/DSpace/DSpace/tree/dspace-5_x).

## Microtagging Code

### Utility Templates
_This file contains custom XSLT templates used by DigitialGeorgetown to theme DSpace_
- [Constant Definitions](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/GU-common2.xsl#L26-L31)
- [Enable/Disable Microtag Output for a Theme](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/GU-common2.xsl#L48)
- [Microtag Generation Templates](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/GU-common2.xsl#L92-L212)

### Page Structure Overrides
_This file is an override of the DSpace Mirage2 page generation template_
- [Website Microtags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/core/page-structure.xsl#L275-L281)
  - [Breadcrumbs](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/core/page-structure.xsl#L548-L609)
  - [Item Page Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/core/page-structure.xsl#L813-L814)
  
### Item Page Overrides
_This file is an override of the DSpace Mirage2 item view template_
- [Summary Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L110)
- [Title Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L187-L225)
- [Abstract Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L271-L298)
- [Tags Applied to linkable terms](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L442-L462)
- [Description Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L551-L578)
- [Author Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L644-L657)
- [URI Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L682-L700)
- [Date Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L721-L739)
- [Detail Page Tags](https://github.com/Georgetown-University-Libraries/DSpaceSolutions/blob/v1_microtag/dspace/modules/xmlui-mirage2/src/main/webapp/themes/Mirage2/xsl/aspect/artifactbrowser/item-view.xsl#L933-L962)
