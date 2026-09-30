@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agency Interface View'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true

define view entity ZUMNGD_I_Agency
  as select from /dmo/agency as Agency


  association [0..1] to I_Country as _Country on $projection.CountryCode = _Country.Country
{
      @ObjectModel.text.element: ['Name']
  key agency_id             as AgencyId,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      @Semantics.organization.name: true
      name                  as Name,

      @Semantics.address.street: true
      street                as Street,

      @Semantics.address.zipCode: true
      postal_code           as PostalCode,

      @Search.defaultSearchElement: true
      @Semantics.address.city: true
      city                  as City,

      @Consumption.valueHelpDefinition: [{entity: { name: 'I_CountryVH', element: 'Country' } }]
      @Semantics.address.country: true
      country_code          as CountryCode,

      @Semantics.telephone.type: [#WORK]
      phone_number          as PhoneNumber,

      @Semantics.eMail.address: true
      email_address         as EmailAddress,
      web_address           as WebAddress,

      @Semantics.largeObject: { mimeType: 'MimeType',
                                  fileName: 'Filename',
                                  contentDispositionPreference: #INLINE }
      attachment            as Attachment,

      @Semantics.mimeType: true
      mime_type             as MimeType,
      filename              as Filename,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,

      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Country
}
