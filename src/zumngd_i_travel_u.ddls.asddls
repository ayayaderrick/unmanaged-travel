@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Interface View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZUMNGD_I_Travel_U
  as select from /dmo/travel as Travel

  composition [0..*] of ZUMNGD_I_Booking_U      as _Booking

  association [0..1] to ZUMNGD_I_Agency         as _Agency       on $projection.AgencyId = _Agency.AgencyId
  association [0..1] to ZUMNGD_I_Customer       as _Customer     on $projection.CustomerId = _Customer.CustomerID
  association [0..1] to I_Currency              as _Currency     on $projection.CurrencyCode = _Currency.Currency
  association [1..1] to /DMO/I_Travel_Status_VH as _TravelStatus on $projection.Status = _TravelStatus.TravelStatus

{
  key travel_id     as TravelId,
      agency_id     as AgencyId,
      customer_id   as CustomerId,
      begin_date    as BeginDate,
      end_date      as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee   as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price   as TotalPrice,

      currency_code as CurrencyCode,
      description   as Memo,
      status        as Status,

      lastchangedat as Lastchangedat,

      _Booking,
      _Agency,
      _Customer,
      _Currency,
      _TravelStatus
}
