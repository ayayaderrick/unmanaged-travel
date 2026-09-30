@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface View'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZUMNGD_I_Booking_U
  as select from /dmo/booking as Booking

  association        to parent ZUMNGD_I_Travel_U as _Travel     on  $projection.TravelId = _Travel.TravelId

  association [1..1] to ZUMNGD_I_Customer        as _Customer   on  $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier           as _Carrier    on  $projection.AirlineID = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _Connection on  $projection.AirlineID    = _Connection.AirlineID
                                                                and $projection.ConnectionId = _Connection.ConnectionID

{
  key travel_id     as TravelId,
  key booking_id    as BookingId,
      booking_date  as BookingDate,
      customer_id   as CustomerId,
      carrier_id    as AirlineID,
      connection_id as ConnectionId,
      flight_date   as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price  as FlightPrice,
      currency_code as CurrencyCode,

      _Travel,
      _Customer,
      _Carrier,
      _Connection
}
