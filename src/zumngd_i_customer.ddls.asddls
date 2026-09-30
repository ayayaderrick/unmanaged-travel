@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Interface View'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true

define view entity ZUMNGD_I_Customer
  as select from /dmo/customer as Customer

  association [0..1] to I_Country as _Country on $projection.CountryCode = _Country.Country

{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['LastName']
  key customer_id   as CustomerID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.name.givenName: true
      first_name    as FirstName,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.name.familyName: true
      @Semantics.text: true
      last_name     as LastName,

      @Semantics.name.prefix: true
      title         as Title,

      @Semantics.address.street: true
      street        as Street,

      @Semantics.address.zipCode: true
      postal_code   as PostalCode,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.address.city: true
      city          as City,

      @Consumption.valueHelpDefinition: [{entity: { name: 'I_CountryVH', element: 'Country' }, useForValidation: true }]
      @Semantics.address.country: true
      country_code  as CountryCode,

      @Semantics.telephone.type: [#HOME]
      phone_number  as PhoneNumber,

      @Semantics.eMail.address: true
      email_address as EMailAddress,

      _Country
}
